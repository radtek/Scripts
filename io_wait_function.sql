prompt dispinivel somente no 11g
SELECT function_name, 
		small_read_reqs + large_read_reqs reads,
		small_write_reqs + large_write_reqs writes,
		wait_time/1000 wait_time_sec,
		CASE WHEN number_of_waits > 0 
			THEN ROUND(wait_time / number_of_waits, 2)
		END avg_wait_ms
FROM v$iostat_function
ORDER BY wait_time DESC;