col sql_id for a20
col SQL_TEXT for a300 wrapped 
SELECT /*+ qb_name(FINDSQLTEXT)*/
		executions, 
		users_executing, 
	   disk_reads,  
	   buffer_gets, 
	   trunc(buffer_gets / executions, 0) as avg_buffer_gets, 
	   cpu_time / 1000 as cpu_time_ms, 
	   elapsed_time / 1000 as elapsed_time_ms ,  
	   SQL_TEXT, 
	   plan_hash_value, 
	   HASH_VALUE
FROM v$sql 
WHERE sql_text LIKE '%&TEXTO%'
and sql_text not like '%FINDSQLTEXT%'
and executions > 0
order by avg_buffer_gets;