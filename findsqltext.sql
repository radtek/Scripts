col sql_id for a20
col SQL_TEXT for a300 wrapped 
col exact_matching_signature for 999999999999999999999999
col force_matching_signature for 999999999999999999999999
SELECT /*+ qb_name(FINDSQLTEXT)*/
		sql_id, 
		ADDRESS,
		HASH_VALUE,		
		child_number, 
		executions, 
		users_executing, 
	   disk_reads,  
	   buffer_gets, 
	   trunc(buffer_gets / executions, 0) as avg_buffer_gets, 
	   cpu_time / 1000 as cpu_time_ms, 
	   elapsed_time / 1000 as elapsed_time_ms ,  
	   ROUND(user_io_wait_time * 100 / elapsed_time, 2) pct_io_time,
	   SQL_TEXT, 
	   plan_hash_value, 
	exact_matching_signature,
	force_matching_signature
FROM v$sql 
WHERE sql_text LIKE '%&TEXTO%'
and sql_text not like '%FINDSQLTEXT%'
and upper(sql_text) not like '%EXPLAIN%'
and upper(sql_text)  not like '%IGNORE%'
and executions > 0
order by avg_buffer_gets;