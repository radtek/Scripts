prompt Não é necessario diagnostic pack, se tem usa @sql_wait_ash
prompt application_time tem TX e TM lock waits, tempo aguardando linha esta disponivel, quanto mais APPLICATION_WAIT_TIMEs então provavel lock contention
prompt app_time = APPLICATION_WAIT_TIME
prompt 			total aguardando "app_time_ms"
prompt 			em relação a outros do "cache pct_of_app_time_total"
prompt 			em relação ao elapsed "app_time_pct"
prompt 
col sql_text format a50 wrapped
col module format a30
col username format a20
col object_name format a30


WITH sql_app_waits AS
(
SELECT sql_id, SUBSTR(sql_text, 1, 80) sql_text,
	 application_wait_time/1000 app_time_ms,
	 elapsed_time,
	 ROUND(application_wait_time * 100 /
	 elapsed_time, 2) app_time_pct,
	 ROUND(application_wait_time * 100 /
	 SUM(application_wait_time) OVER (), 2) pct_of_app_time_total,
	 RANK() OVER (ORDER BY application_wait_Time DESC) ranking
FROM v$sql
WHERE elapsed_time > 0 AND application_wait_time>0
)
SELECT sql_text, app_time_ms, app_time_pct,
	pct_of_app_time_total
FROM sql_app_waits
WHERE ranking <= 10
ORDER BY ranking ;				