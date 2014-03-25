prompt demostra o result cache ratios
prompt Find/Create PCT < 100 então revisar consultas com RESULT_CACHE
prompt 
WITH execs AS 
(
 SELECT VALUE executions
 FROM v$sysstat
 WHERE name = 'execute count'
),
rscache AS
(
 SELECT SUM(DECODE(name, 'Create Count Success',VALUE)) created,
	 SUM(DECODE(name, 'Find Count', VALUE)) find_count
 FROM v$result_cache_statistics
),
rscounts AS 
(
 SELECT COUNT( * ) resultSets,
	 COUNT(DISTINCT cache_id) statements
 FROM v$result_cache_objects
 WHERE TYPE = 'Result'
)
SELECT resultSets, 
	statements, 
	created,
	 find_count / 1000 find_count1000,
	 ROUND(find_count * 100 / created, 2) find_created_pct,
	 executions / 1000 execs1000,
	 ROUND(find_count * 100 / executions, 2) find_exec_pct
FROM rscache 
	CROSS JOIN execs
	CROSS JOIN rscounts;