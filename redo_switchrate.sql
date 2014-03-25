prompt LAG calcula a diferença da linha atual com a linha anterior
prompt 
WITH log_history AS
(
	SELECT thread#, 
		first_time,
		LAG(first_time) OVER (ORDER BY thread#, sequence#)
	 	last_first_time,
		 (first_time - LAG(first_time) OVER (ORDER BY thread#, sequence#)) * 24* 60 last_log_time_minutes,
		 LAG(thread#) OVER (ORDER BY thread#, sequence#) last_thread#
	 FROM v$log_history
)
 SELECT ROUND(MIN(last_log_time_minutes), 2) min_minutes,
 	ROUND(MAX(last_log_time_minutes), 2) max_minutes,
	 ROUND(AVG(last_log_time_minutes), 2) avg_minutes
 FROM log_history
 WHERE last_first_time IS NOT NULL
	 AND last_thread# = thread#
	 AND first_time > SYSDATE - 1;
