prompt determina os sqls que tem mais dependencia latch consultando ASH
prompt necessario diagnostic pack
prompt
col event format a30
col module format a15
col username format a20
col object_name format a30
col SQL_TEXT format a100 wrapped

WITH ash_query AS 
(
	SELECT event, 
		program,
		h.module, 
		h.action, 
		object_name,
		SUM(time_waited)/1000 time_ms, COUNT( * ) waits,
		username, 
		sql_text,
		RANK() OVER (ORDER BY SUM(time_waited) DESC) AS time_rank,
		ROUND(SUM(time_waited) * 100 / SUM(SUM(time_waited))OVER (), 2) pct_of_time
	FROM v$active_session_history h
		JOIN dba_users u 
			USING (user_id)
		LEFT OUTER JOIN dba_objects o
			ON (o.object_id = h.current_obj#)
		LEFT OUTER JOIN v$sql s 
			USING (sql_id)
	WHERE event LIKE '%latch%' or event like '%mutex%'
	GROUP BY event,program, h.module, h.action, object_name, sql_text, username
)
 SELECT event,module, username, object_name, time_ms, pct_of_time, sql_text
 FROM ash_query
 WHERE time_rank < 11
 ORDER BY time_rank;