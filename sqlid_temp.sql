select 
	sql_id, 
	CHILD_NUMBER, 
	operation_type as op, 
	operation_id as id, 
	policy,
	round(estimated_optimal_size/1024/1024) as estimated_optimal_MB, 
	round(estimated_onepass_size/1024/1024) as estimated_onepass,
	round(last_memory_used/1024/1024) as last_memused_MB, 
	last_execution as last,
	total_executions as tot_exec, 
	optimal_executions as opt_execs, 
	onepass_executions as onepass_execs, 
	multipasses_executions as multpass_execs,
	round(active_time/1000000,2) as Activesec, 
	round(max_tempseg_size/1024/1024,2) as tmp_segsize_MB, 
	round(last_tempseg_size/1024/1024,2) as tmp_Last_segsize_MB
from v$sql_workarea 
where SQL_ID = '&sqlid'
order by sql_id, CHILD_NUMBER;
