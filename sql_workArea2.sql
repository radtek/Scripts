WITH sql_workarea AS
(
	SELECT sql_id || '-' || child_number SQL_ID_Child,
		operation_type operation ,
		last_execution last_exec,
		ROUND (active_time / 1000000,2) seconds,
		optimal_executions || '/' || onepass_executions || '/' || multipasses_executions o1m,
		' ' || SUBSTR (sql_text, 1, 155) sql_text,
		RANK () OVER (ORDER BY active_time DESC) ranking
	FROM v$sql_workarea JOIN v$sql
	USING (sql_id, child_number) 
)
SELECT sql_id_child "SQL ID - CHILD",seconds,operation,
last_exec, o1m "O/1/M",sql_text
FROM sql_workarea
WHERE ranking <= 2
ORDER BY ranking;