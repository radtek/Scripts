prompt latch row cache, cache do dicionário de dados
prompt precisa executar como sys
prompt 
SELECT kqrsttxt namespace, child#, misses, sleeps,wait_time, ROUND(wait_time*100/sum(wait_time) over(),2) pct_wait_Time
FROM v$latch_children
		JOIN (SELECT DISTINCT kqrsttxt, kqrstcln 
			  FROM x$kqrst) kqrst 
			ON (kqrstcln = child#)
WHERE name = 'row cache objects' 
AND wait_Time > 0
ORDER BY wait_time DESC;				