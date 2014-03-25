prompt somente reporta wait por user para sessoes ativas
prompt
WITH session_event AS
(
	SELECT CASE WHEN event LIKE 'enq:%' THEN event ELSE wait_class END wait_type, e.*
	FROM v$session_event e 
 )
SELECT wait_type,SUM(total_waits) total_waits,
	round(SUM(time_waited_micro)/1000000,2) time_waited_seconds,
	ROUND( SUM(time_waited_micro) * 100 / SUM(SUM(time_waited_micro)) OVER (), 2) pct
FROM (SELECT e.sid, wait_type, event, total_waits, time_waited_micro
	  FROM session_event e
	  UNION
	  SELECT sid, 'CPU', stat_name, NULL, VALUE
	  FROM v$sess_time_model
	  WHERE stat_name IN ('background cpu time', 'DB CPU')) l
WHERE wait_type <> 'Idle'
and sid in (select sid from v$session where username='&USERNAME')
GROUP BY wait_type
ORDER BY 4 DESC
/