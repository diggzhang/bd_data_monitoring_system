--! create table
CREATE TABLE metrics_alert_metadata
(
    id SERIAL PRIMARY KEY,
    day TIMESTAMP,
    event_key TEXT NOT NULL,
    platform TEXT NOT NULL,
    os TEXT NOT NULL,
    pv_ring_ratio NUMERIC,
    uv_ring_ratio NUMERIC,
    warning_level_status TEXT, --! serious>general>caveat>normal
    pv_per_user_ratio NUMERIC, --! 目前计算含义不明
    creat_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
)

--! create index
CREATE INDEX idx_metrics_alert_event_key_warning_level_status ON metrics_alert_metadata USING btree(event_key, warning_level_status);

--！计算某日环比的逻辑
insert into metrics_alert_metadata(day, event_key, platform, os, pv_ring_ratio, uv_ring_ratio, warning_level_status )
select 
  ring_ration.day as day,
  ring_ration.event_key as event_key,
  ring_ration.platform as platform,
  ring_ration.os as os,
  ring_ration.percentofpv as pv_ring_ratio,
  ring_ration.percentofuv as uv_ring_ratio,
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