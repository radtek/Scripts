prompt o tempo de concurrency deve ser baixo
prompt waits deve ser abaixo de ~10%
prompt se maior detalhar qual wait em rac_waits
prompt 
SELECT wait_class time_cat ,
	ROUND ( (time_secs), 2) time_secs,
	ROUND ((time_secs) * 100 / SUM(time_secs) OVER (),2) pct
FROM (SELECT wait_class wait_class,
			 sum(time_waited_micro) / 1000000 time_secs
	  FROM gv$system_event
	  WHERE wait_class <> 'Idle'
		AND time_waited > 0
	  GROUP BY wait_class
	  UNION
	  SELECT 'CPU',
		 ROUND((SUM(VALUE) / 1000000),2) time_secs
	  FROM gv$sys_time_model
	  WHERE stat_name IN ('background cpu time', 'DB CPU'))
ORDER BY time_secs DESC;