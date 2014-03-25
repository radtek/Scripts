undef sqlid

Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
define sqlid=&sqlid

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

Select Min(Snap_id), Max(snap_id), Count(*) Nro_ocorrencias, Count(Distinct Plan_hash_value) Nro_planos_distintos
from dba_hist_sqlstat
where sql_id = '&sqlid';

prompt ***********TOTAL Delta values snap_id AWR
select  hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,
	SUM(COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1)) as EXECUTIONS,
	SUM(ss.DISK_READS_DELTA) as DISK_READS,
	SUM(ss.BUFFER_GETS_DELTA) AS BUFFER_GETS,
	SUM(ss.ROWS_PROCESSED_DELTA) AS ROWS_PROCESSED,
	SUM(round(ss.CPU_TIME_DELTA / 1000)) AS CPU_TIME_MS,
	SUM(round(ss.ELAPSED_TIME_DELTA / 1000)) AS ELAPSED_TIME_MS,
	SUM(ss.FETCHES_DELTA) AS FETCHES,
	SUM(ss.SORTS_DELTA) AS SORTS,
	SUM(ss.PARSE_CALLS_DELTA) AS PARSE_CALLS,
	SUM(ss.PX_SERVERS_EXECS_DELTA) AS PX_SERVERS_EXECS, 
	PARSING_SCHEMA_NAME, 
	PLAN_HASH_VALUE
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where sql_id='&sqlid'
and  hs.snap_id between :Snap_ini and :Snap_fim
group by hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI'), PARSING_SCHEMA_NAME, PLAN_HASH_VALUE
order by PARSING_SCHEMA_NAME, hs.snap_id;

prompt ***********AVG Delta values por snap_id AWR
select  hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,	
	SUM(ROUND(ss.DISK_READS_DELTA / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1))) as DISK_READS_AVG,
	SUM(ROUND(ss.BUFFER_GETS_DELTA / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1))) AS BUFFER_GETS_AVG,
	SUM(ROUND(ss.ROWS_PROCESSED_DELTA / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1))) AS ROWS_PROCESSED_AVG,
	SUM(ROUND(ss.CPU_TIME_DELTA  / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1) / 1000)) AS CPU_TIME_MS_AVG,
	SUM(ROUND((ss.ELAPSED_TIME_DELTA  / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1)) / 1000)) AS ELAPSED_TIME_MS_AVG,
	SUM(ROUND(ss.FETCHES_DELTA  / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1))) AS FETCHES_AVG,
	SUM(ROUND(ss.SORTS_DELTA  / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1))) AS SORTS_AVG,
	SUM(ROUND(ss.PARSE_CALLS_DELTA  / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1))) AS PARSE_CALLS_AVG,
	SUM(ROUND(ss.PX_SERVERS_EXECS_DELTA  / COALESCE(NULLIF(ss.EXECUTIONS_DELTA,0), 1))) AS PX_SERVERS_EXECS_AVG, 
	SUM(ROUND((ss.ELAPSED_TIME_DELTA  / nullif(ss.ROWS_PROCESSED_DELTA,0)) / 1000)) AS ELAPSED_TIME_MS_AVG_BY_ROW,
	PARSING_SCHEMA_NAME, 
	PLAN_HASH_VALUE
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where sql_id='&sqlid'
and  hs.snap_id between :Snap_ini and :Snap_fim
group by hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI'), PARSING_SCHEMA_NAME, PLAN_HASH_VALUE
order by PARSING_SCHEMA_NAME, hs.snap_id;


prompt ***********Outros Delta values por snap_id AWR
select hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,
	SUM(ROUND(ss.IOWAIT_DELTA / 1000)) AS IOWAIT_MS,
	SUM(ROUND(ss.CLWAIT_DELTA / 1000)) AS CLWAIT_MS,
	SUM(ROUND(ss.APWAIT_DELTA / 1000)) AS APWAIT_MS,
	SUM(ROUND(ss.CCWAIT_DELTA / 1000)) AS CCWAIT_MS,
	SUM(ROUND(ss.PLSEXEC_TIME_DELTA / 1000)) AS PLSEXEC_TIME_MS,
	SUM(ROUND(ss.JAVEXEC_TIME_DELTA / 1000)) AS JAVEXEC_TIME_MS,
	ss.optimizer_mode,
	ss.parsing_schema_name, 
	ss.PLAN_HASH_VALUE
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where sql_id='&sqlid'
and  hs.snap_id between :Snap_ini and :Snap_fim
group by hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') , ss.optimizer_mode, ss.parsing_schema_name, ss.PLAN_HASH_VALUE
order by PARSING_SCHEMA_NAME, hs.snap_id;

prompt *********** Plano de execução
SELECT *
FROM  TABLE(DBMS_XPLAN.DISPLAY_AWR('&sqlid', null, null,  'ALL' ));

prompt *********** bind values
Select * from (
	Select SNAP_ID, INSTANCE_NUMBER, NAME, POSITION, DATATYPE_STRING, VALUE_STRING
	from DBA_HIST_SQLBIND A
	where A.sql_id = '&sqlid'
	   and  a.snap_id between :Snap_ini and :Snap_fim
	 Order by snap_id desc, NAME)
where rownum < 50;

prompt *********** SQL Text
Select sql_text
from DBA_HIST_SQLTEXT
where sql_id = '&sqlid';


undef dt1
undef dt2
undef sqlid
set verify on