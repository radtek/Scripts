prompt identificar consultas n�o est�o usando bind
col SQL for a50
SELECT 
	substr(sql_text,1,40) "SQL",
	count(*) ,
	sum(executions) "TotExecs"
FROM v$sqlarea
WHERE executions < 5
GROUP BY substr(sql_text,1,40)
HAVING count(*) > 30
ORDER BY 2;
