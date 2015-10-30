SELECT low_optimal_size/1024 low_kb,
	(high_optimal_size+1)/1024 high_kb,
	optimal_executions, onepass_executions, multipasses_executions
FROM V$SQL_WORKAREA_HISTOGRAM
WHERE total_executions != 0;


SELECT name profile, cnt, DECODE(total, 0, 0, ROUND(cnt*100/total)) percentage
FROM (SELECT name, value cnt, (SUM(value) over ()) total
FROM V$SYSSTAT
WHERE name
LIKE 'workarea exec%');