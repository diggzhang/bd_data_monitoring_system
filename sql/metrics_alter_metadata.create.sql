--! 报警表结构
create table metrics_alert_metadata
(
    event_key text,  -- 哪个eventKey计算有问题了
    platform text,
    os text,
    pv_ring_ratio, -- 环比增长幅
    uv_ring_ratio, 
    warning_level_status text, -- 报警级别是啥

    pv_per_user_ratio, -- 这个数据的意义是什么，有没有更好的直观指标

    create_date timestamp, -- 代表几号报警
    update_date timestamp
)

--！计算某日环比的逻辑
select 
  ring_ration.event_key,
  ring_ration.platform,
  ring_ration.os,
  ring_ration.percentofpv,
  ring_ration.percentofuv,
  case 
  	when ring_ration.abs_uv >= 0.5 or ring_ration.abs_pv >= 0.5
      then 'serious'
    when (ring_ration.abs_uv < 0.5 and ring_ration.abs_uv >= 0.3) or (ring_ration.abs_pv < 0.5 and ring_ration.abs_pv >= 0.3) 
      then 'general'
	  when (ring_ration.abs_uv < 0.3 and ring_ration.abs_uv > 0.2) or (ring_ration.abs_pv < 0.3 and ring_ration.abs_pv > 0.2)
	    then 'caveat'
	  when ring_ration.abs_uv <= 0.2 or ring_ration.abs_pv <= 0.2
	    then 'normal'
  end as warning_level_status
  ring_ration.day
from 
(
  select 
    today.event_key,
    today.platform,
    today.os,
    today.day,
    (today.pv - yesterday.pv) / yesterday.pv::float as percentofpv,
    (today.uv - yesterday.uv) / yesterday.pv::float as percentofuv,
    abs((today.pv - yesterday.pv) / yesterday.pv::float) as abs_pv,
    abs((today.uv - yesterday.uv) / yesterday.uv::float) as abs_uv
  from (
	  select * from metrics_metadata where day='20180909'
  ) as today 
  join (
	  select * from metrics_metadata where day='20180908'
  ) as yesterday
    on today.event_key = yesterday.event_key
    and today.os = yesterday.os
    and today.platform = yesterday.platform
) as ring_ration