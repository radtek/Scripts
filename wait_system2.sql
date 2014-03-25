column wait_class format a20
column event format a35

select *
FROM (
	SELECT wait_class, event, total_waits AS waits,
		ROUND (time_waited_micro / 1000) AS total_ms,
		ROUND (time_waited_micro * 100 / SUM (time_waited_micro) OVER (),2) AS pct_time,
		ROUND ((time_waited_micro / total_waits) / 1000, 2) AS avg_ms
	FROM v$system_event
	WHERE wait_class <> 'Idle'
	ORDER BY time_waited_micro DESC )
WHERE rownum < 20	;