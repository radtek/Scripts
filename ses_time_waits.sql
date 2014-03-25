define sid=&sid

COLUMN wait_class format a20
COLUMN name       format a30
COLUMN time_secs  format 999,999,999,999.99
COLUMN pct        format 99.99

SELECT *
FROM 
(SELECT   
   wait_class, 
   NAME, 
   ROUND (time_secs, 2) time_secs,
   ROUND (time_secs * 100 / SUM (time_secs) OVER (), 2) pct
FROM 
   (SELECT 
      n.wait_class, 
      e.event NAME, 
      e.time_waited / 100 time_secs
    FROM 
      v$session_event e, 
      v$event_name n
    WHERE 
       n.NAME = e.event AND n.wait_class <> 'Idle'
     and e.sid = &sid
    AND 
       time_waited > 0
    UNION
    SELECT 
      'CPU', 
      'server CPU', 
      SUM (VALUE / 1000000) time_secs
    FROM 
      v$sess_time_model
    WHERE 
      stat_name IN ('background cpu time', 'DB CPU')
    and sid=&sid) tbl
) TBL
WHERE pct > 0.1
ORDER BY 
   time_secs DESC;


undef sid