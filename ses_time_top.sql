SELECT
   s.sid, 
   s.username,
   s.module,
   round(t.value/1000000,2) "Elapsed Processing Time (Sec)"
FROM
   v$sess_time_model t,
   v$session s
WHERE
   t.sid = s.sid
AND 
   t.stat_name = 'DB time'
AND 
  s.username IS NOT NULL 
AND 
   t.value/1000000 >= 1
order by "Elapsed Processing Time (Sec)" desc;

