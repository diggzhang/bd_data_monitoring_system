--! 生成一周的埋点测试数据
--! 逗号分隔的csv文件
--！day,event_key,platform,os,pv,uv
set hive.execution.engine=mr;

INSERT OVERWRITE LOCAL DIRECTORY '/home/master/xingze/matrix_point'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT day, event_key, platform, os, count(id) as pv, count(DISTINCT u_user) as uv
FROM events.frontend_event_orc
WHERE day BETWEEN 20180906 AND 20180912
  AND event_key != ''
  AND platform IN ('miniprogramForParents', 'miniprogramForPrimaryMath', 'miniprogramForGrowthMath', 'app')
  AND os in ('ios', 'android', 'other')
GROUP BY day, event_key, platform, os
ORDER BY uv DESC
