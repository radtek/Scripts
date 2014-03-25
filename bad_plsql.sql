col sql_text format a150

SELECT *
FROM (SELECT sql_id,
		ROUND (elapsed_time / 1000) AS elapsed_ms,
		ROUND (plsql_exec_time / 1000) plsql_ms,
		ROUND (plsql_exec_time * 100 / elapsed_time, 2) pct_plsql,
		ROUND (plsql_exec_time * 100 / SUM (plsql_exec_time) OVER (), 2) pct_total_plsql, 
		SUBSTR (sql_text, 1, 150) AS sql_text,
		plsql_exec_time
	 FROM v$sql
	 WHERE plsql_exec_time > 0 AND elapsed_time > 0
	 ORDER BY plsql_exec_time DESC) TBL
WHERE ROWNUM < 10
order by plsql_exec_time DESC;