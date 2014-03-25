SELECT  memory_size, 
	memory_size_factor * 100 memory_size_pct,
	estd_db_time_factor * 100 estd_db_time_pct, 
	estd_db_time
FROM v$memory_target_advice a
ORDER BY memory_size_factor;