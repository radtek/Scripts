prompt determina os sqls que tem mais dependencia latch, mutex, lock internos ou buffer waits analisando o concurrency_wait_time
prompt
col event format a30
col module format a15
col username format a20
col object_name format a30
col SQL_TEXT format a100 wrapped


WITH sql_conc_waits AS
(
 SELECT sql_id, SUBSTR(sql_text, 1, 100) sql_text,
   	concurrency_wait_time/1000 con_time_ms,
	 elapsed_time,
	 ROUND(concurrency_wait_Time * 100 / elapsed_time, 2) con_time_pct,
	 ROUND(concurrency_wait_Time* 100 / SUM(concurrency_wait_Time) OVER (), 2) pct_of_con_time,
	 RANK() OVER (ORDER BY concurrency_wait_Time DESC) ranking
 FROM v$sql
 WHERE elapsed_time > 0
)
 SELECT sql_text, con_time_ms, con_time_pct, pct_of_con_time
 FROM sql_conc_waits
 WHERE ranking <= 10
 ORDER BY ranking;