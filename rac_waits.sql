prompt detalhadamente cada wait do gc
prompt waits do gc não devem ser maior que 10%
prompt 
WITH system_event AS
(
 SELECT CASE WHEN wait_class = 'Cluster' 
			THEN event
			ELSE wait_class
		END wait_type, 
		e.*
 FROM gv$system_event e
 )
SELECT wait_type, 
		ROUND(total_waits/1000,2) waits_1000 ,
		ROUND(time_waited_micro/1000000/3600,2) time_waited_hours,
		ROUND(time_waited_micro/1000/total_waits,2) avg_wait_ms ,
		ROUND(time_waited_micro*100 /SUM(time_waited_micro) OVER(),2) pct_time
FROM (SELECT wait_type, 
			SUM(total_waits) total_waits,
			SUM(time_waited_micro) time_waited_micro
	  FROM system_event e
	  GROUP BY wait_type
	  UNION
	  SELECT 'CPU', 
			NULL, 
			SUM(VALUE)
	  FROM gv$sys_time_model
	  WHERE stat_name IN ('background cpu time', 'DB CPU'))
WHERE wait_type <> 'Idle'
ORDER BY time_waited_micro DESC;