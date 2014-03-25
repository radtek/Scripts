define sqlid = &sql_id

col is_bind_sensitive for a10
col is_bind_aware for a10
col IS_SHAREABLE for a10
col IS_OBSOLETE for a10

SELECT child_number, is_bind_sensitive, is_bind_aware, IS_SHAREABLE, IS_OBSOLETE, plan_hash_value
FROM   v$sql
WHERE  sql_id  = '&sqlid'
order by CHILD_NUMBER;


SELECT 
	CHILD_NUMBER,
	EXECUTIONS,
	ROWS_PROCESSED,
	BUFFER_GETS, 
	CPU_TIME,
	ROUND(ROWS_PROCESSED / EXECUTIONS) AVG_ROWS,
	ROUND(BUFFER_GETS / EXECUTIONS) AVG_GETS,
	ROUND(CPU_TIME / EXECUTIONS) AVG_CPU
FROM V$SQL_CS_STATISTICS
WHERE SQL_ID = '&sqlid'
order by CHILD_NUMBER;

SELECT * 
FROM v$sql_cs_selectivity 
WHERE sql_id = '&sqlid'
order by CHILD_NUMBER;


undefine sqlid