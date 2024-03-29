--> CPU quebrado por wait
SELECT event, 
	total_waits,
	ROUND (time_waited_micro / 1000000) AS time_waited_secs,
	ROUND (time_waited_micro * 100 / SUM (time_waited_micro) OVER (),2) AS pct_time
FROM (SELECT event, total_waits, time_waited_micro
	FROM v$system_event
	WHERE wait_class <> 'Idle'
	UNION
	SELECT stat_name, NULL, VALUE
	FROM v$sys_time_model
	WHERE stat_name IN ('DB CPU', 'background cpu time'))
ORDER BY 3 DESC;