SELECT 
  to_char(m.begin_time,'hh24:mi') "start time",
  to_char(m.end_time,'hh24:mi')   "end time",
  m.value                         "current value",
  s.average                       "average value",
  m.metric_name,
  m.metric_unit
FROM 
  v$sysmetric         m,
  v$sysmetric_summary s
WHERE
      m.metric_id = s.metric_id
  AND s.average > 0    
  AND ((m.value - s.average)/s.average)*100 >= 10
  AND lower(m.metric_name) LIKE '%User Calls%'
/