prompt todos waits time desde ultimo restart
prompt 
WITH system_event AS
 (
  SELECT CASE WHEN (event LIKE '%latch%' or event
				LIKE '%mutex%' or event like 'cursor:%')
				THEN event ELSE wait_class
			END wait_type, e.*
  FROM v$system_event e
 )
 SELECT wait_type,SUM(total_waits) total_waits,
		round(SUM(time_waited_micro)/1000000,2) time_waited_seconds,
		ROUND( SUM(time_waited_micro) * 100 / SUM(SUM(time_waited_micro)) OVER (), 2) pct
FROM (  SELECT wait_type, event, total_waits, time_waited_micro
		FROM system_event e
		UNION
		SELECT 'CPU', stat_name, NULL, VALUE
		FROM V$sys_time_model
		WHERE stat_name IN ('background cpu time', 'DB CPU')) l
WHERE wait_type <> 'Idle'
GROUP BY wait_type
ORDER BY 4 DESC
/