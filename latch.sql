prompt lista todos os latch genericos e especificos que também estão dispinivel em v$system_event script "sys_time_latch.sql"
col name format a40

WITH latch AS 
(
	SELECT name,
		ROUND(gets * 100 / SUM(gets) OVER (), 2) pct_of_gets,
		ROUND(misses * 100 / SUM(misses) OVER (), 2) pct_of_misses,
		ROUND(sleeps * 100 / SUM(sleeps) OVER (), 2) pct_of_sleeps,
		ROUND(wait_time * 100 / SUM(wait_time) OVER (), 2) pct_of_wait_time
	FROM v$latch
)
SELECT *
FROM latch
WHERE pct_of_wait_time > .1 OR pct_of_sleeps > .1
ORDER BY pct_of_wait_time DESC;
