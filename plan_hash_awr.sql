undef PLAN_HASH_VALUE

Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
define PLAN_HASH_VALUE=&PLAN_HASH_VALUE

col VALUE_STRING for a20
col END_INTERVAL_TIME format a17
col ELAPSED_TIME_MS_AVG format 999999999999
col EXECUTIONS for 999999999999 justify right
col DISK_READS  for 999999999999 justify right
col BUFFER_GETS for 999999999999 justify right
col ROWS_PROCESSED for 999999999999 justify right
col CPU_TIME_MS for 999999999999 justify right
col ELAPSED_TIME_MS for 999999999999 justify right
col FETCHES for 999999999999 justify right
col SORTS for 999999999999 justify right
col PARSE_CALLS for 999999999999 justify right
col PX_SERVERS_EXECS for 999999999999 justify right
col DISK_READS_AVG for 999999999999 justify right
col BUFFER_GETS_AVG for 999999999999 justify right
col ROWS_PROCESSED_AVG for 999999999999 justify right
col CPU_TIME_MS_AVG for 999999999999 justify right
col ELAPSED_TIME_MS_AVG for 999999999999 justify right
col FETCHES_AVG for 999999999999 justify right
col SORTS_AVG for 999999999999 justify right
col PARSE_CALLS_AVG for 999999999999 justify right
col PX_SERVERS_EXECS_AVG for 999999999999 justify right

--col sql_text format a9999

set long 99999
set verify off

var Snap_ini number
var Snap_fim number

prompt *********** History Snapshot

begin 
	Select MIN(snap_id), MAX(snap_id)
	INTO :Snap_ini, :Snap_fim
	from dba_hist_snapshot
	where end_interval_time between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss');
end;
/

Select *
from dba_hist_snapshot
where snap_id In (:Snap_ini, :Snap_fim)
Order by instance_number, snap_id;

Select Min(Snap_id), Max(snap_id), Count(*) Nro_ocorrencias, Count(Distinct sql_id) Nro_SQL_IDS
from dba_hist_sqlstat
where PLAN_HASH_VALUE = '&PLAN_HASH_VALUE';

prompt ***********TOTAL Delta values snap_id AWR
select  hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,
	SUM(ss.EXECUTIONS_DELTA) as EXECUTIONS,
	SUM(ss.DISK_READS_DELTA) as DISK_READS,
	SUM(ss.BUFFER_GETS_DELTA) AS BUFFER_GETS,
	SUM(ss.ROWS_PROCESSED_DELTA) AS ROWS_PROCESSED,
	SUM(round(ss.CPU_TIME_DELTA 	/ 1000)) AS CPU_TIME_MS,
	SUM(round(ss.ELAPSED_TIME_DELTA / 1000)) AS ELAPSED_TIME_MS,
	SUM(ss.FETCHES_DELTA) AS FETCHES,
	SUM(ss.SORTS_DELTA) AS SORTS,
	SUM(ss.PARSE_CALLS_DELTA) AS PARSE_CALLS,
	SUM(ss.PX_SERVERS_EXECS_DELTA) AS PX_SERVERS_EXECS, 
	PARSING_SCHEMA_NAME
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where PLAN_HASH_VALUE='&PLAN_HASH_VALUE'
and  hs.snap_id between :Snap_ini and :Snap_fim
group by hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI'), PARSING_SCHEMA_NAME
ORDER BY PARSING_SCHEMA_NAME, hs.snap_id;

prompt ***********AVG Delta values por snap_id AWR
select  hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,	
	ROUND(SUM(ss.DISK_READS_DELTA) 				/ SUM(ss.EXECUTIONS_DELTA)) as DISK_READS_AVG,
	ROUND(SUM(ss.BUFFER_GETS_DELTA) 			/ SUM(ss.EXECUTIONS_DELTA)) AS BUFFER_GETS_AVG,
	ROUND(SUM(ss.ROWS_PROCESSED_DELTA) 			/ SUM(ss.EXECUTIONS_DELTA)) AS ROWS_PROCESSED_AVG,
	ROUND((SUM(ss.CPU_TIME_DELTA)      / 1000) 	/ SUM(ss.EXECUTIONS_DELTA)) AS CPU_TIME_MS_AVG,
	ROUND((SUM(ss.ELAPSED_TIME_DELTA)  / 1000)  / SUM(ss.EXECUTIONS_DELTA)) AS ELAPSED_TIME_MS_AVG,
	ROUND(SUM(ss.FETCHES_DELTA) 				/ SUM(ss.EXECUTIONS_DELTA)) AS FETCHES_AVG,
	ROUND(SUM(ss.SORTS_DELTA) 					/ SUM(ss.EXECUTIONS_DELTA)) AS SORTS_AVG,
	ROUND(SUM(ss.PARSE_CALLS_DELTA) 			/ SUM(ss.EXECUTIONS_DELTA)) AS PARSE_CALLS_AVG,
	ROUND(SUM(ss.PX_SERVERS_EXECS_DELTA) 		/ SUM(ss.EXECUTIONS_DELTA)) AS PX_SERVERS_EXECS_AVG, 
	PARSING_SCHEMA_NAME	
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where PLAN_HASH_VALUE='&PLAN_HASH_VALUE'
and  hs.snap_id between :Snap_ini and :Snap_fim
and ss.EXECUTIONS_DELTA > 0
group by hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI'), PARSING_SCHEMA_NAME
ORDER BY PARSING_SCHEMA_NAME, hs.snap_id;


prompt ***********Outros Delta values por snap_id AWR
select hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,
	SUM(ROUND(ss.IOWAIT_DELTA / 1000)) AS IOWAIT_MS,
	SUM(ROUND(ss.CLWAIT_DELTA / 1000)) AS CLWAIT_MS,
	SUM(ROUND(ss.APWAIT_DELTA / 1000)) AS APWAIT_MS,
	SUM(ROUND(ss.CCWAIT_DELTA / 1000)) AS CCWAIT_MS,
	SUM(ROUND(ss.PLSEXEC_TIME_DELTA / 1000)) AS PLSEXEC_TIME_MS,
	SUM(ROUND(ss.JAVEXEC_TIME_DELTA / 1000)) AS JAVEXEC_TIME_MS,
	ss.optimizer_mode,
	ss.parsing_schema_name	
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where PLAN_HASH_VALUE='&PLAN_HASH_VALUE'
and  hs.snap_id between :Snap_ini and :Snap_fim
group by hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') , ss.optimizer_mode, ss.parsing_schema_name
ORDER BY PARSING_SCHEMA_NAME, hs.snap_id;


Select Distinct sql_id
from dba_hist_sqlstat
where PLAN_HASH_VALUE = '&PLAN_HASH_VALUE'
and rownum < 10;

undef dt1
undef dt2
undef PLAN_HASH_VALUE
set verify on
