prompt Informe 1 se quer listar somente o que tiver executando 
define EXECUTING=&EXECUTING

col USERNAME for a20
col process_name for a20
col MODULE for a20
col CLIENT_IDENTIFIER for a20
col EXACT_MATCHING_SIGNATURE for 99999999999999999999999999999
col FORCE_MATCHING_SIGNATURE for 99999999999999999999999999999
col key for 9999999999999999999999999

SELECT 
	key,
	USERNAME,
	process_name,
	sid, 
	sql_id, 
	sql_exec_id, 
	sql_exec_start, 
	status,
	round(elapsed_time / 1000) as elapsed_time_ms,
	round(cpu_time / 1000) as cpu_time_ms,
	round(QUEUING_TIME / 1000) as queuing_time_ms,
	FETCHES, 
	BUFFER_GETS,
	DISK_READS, 
	DIRECT_WRITES,	
	MODULE,
	CLIENT_IDENTIFIER,
	PROGRAM, 
	EXACT_MATCHING_SIGNATURE,
	FORCE_MATCHING_SIGNATURE,
	ERROR_NUMBER, 
	last_refresh_time
from v$sql_monitor
where (&EXECUTING = 0 or status = 'EXECUTING')
order by sql_exec_start;

undefine EXECUTING