prompt waits relacionado com redo log
WITH system_event AS
(
 SELECT CASE WHEN event LIKE 'log file%'
	 	THEN event ELSE wait_class
	END wait_type, 
	e.*
 FROM v$system_event e
)
 SELECT wait_type, 
	SUM(total_waits) / 1000 waits_1000,
 	ROUND(SUM(time_waited_micro) / 1000000 / 3600, 2) time_waited_hours,
	ROUND(SUM(time_waited_micro) / SUM(total_waits) / 1000, 2) avg_wait_ms,
	ROUND( SUM(time_waited_micro) * 100 / SUM(SUM(time_waited_micro)) OVER (), 2) pct
 FROM (SELECT wait_type, 
		event, 
		total_waits, 
		time_waited_micro
	 FROM system_event e
	 UNION
	 SELECT 'CPU', 
		stat_name, 
		NULL, 
		VALUE
	 FROM v$sys_time_model
	 WHERE stat_name IN ('background cpu time', 'DB CPU')
	) l
 WHERE wait_type <> 'Idle'
 GROUP BY wait_type
 ORDER BY SUM(time_waited_micro) DESC;
