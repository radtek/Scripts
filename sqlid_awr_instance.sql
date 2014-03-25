col END_INTERVAL_TIME format a17
define daysago=&daysago
define sqlid=&sqlid


prompt TOTAL Delta values por hora AWR
select  hs.snap_id, hs.instance_number, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,
	ss.EXECUTIONS_DELTA as EXECUTIONS,
	ss.DISK_READS_DELTA as DISK_READS,
	ss.BUFFER_GETS_DELTA AS BUFFER_GETS,
	ss.ROWS_PROCESSED_DELTA AS ROWS_PROCESSED,
	ss.CPU_TIME_DELTA AS CPU_TIME,
	ss.ELAPSED_TIME_DELTA AS ELAPSED_TIME,
	ss.FETCHES_DELTA AS FETCHES,
	ss.SORTS_DELTA AS SORTS,
	ss.PARSE_CALLS_DELTA AS PARSE_CALLS,
	ss.PX_SERVERS_EXECS_DELTA AS PX_SERVERS_EXECS
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where sql_id='&sqlid'
and hs.end_interval_time > sysdate - &daysago
order by hs.snap_id;

prompt AVG Delta values por hora AWR
select  hs.snap_id, hs.instance_number, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,	
	ROUND(ss.DISK_READS_DELTA / ss.EXECUTIONS_DELTA) as DISK_READS_AVG,
	ROUND(ss.BUFFER_GETS_DELTA / ss.EXECUTIONS_DELTA) AS BUFFER_GETS_AVG,
	ROUND(ss.ROWS_PROCESSED_DELTA / ss.EXECUTIONS_DELTA) AS ROWS_PROCESSED_AVG,
	ROUND(ss.CPU_TIME_DELTA  / ss.EXECUTIONS_DELTA) AS CPU_TIME_AVG,
	ROUND(ss.ELAPSED_TIME_DELTA  / ss.EXECUTIONS_DELTA) AS ELAPSED_TIME_AVG,
	ROUND(ss.FETCHES_DELTA  / ss.EXECUTIONS_DELTA) AS FETCHES_AVG,
	ROUND(ss.SORTS_DELTA  / ss.EXECUTIONS_DELTA) AS SORTS_AVG,
	ROUND(ss.PARSE_CALLS_DELTA  / ss.EXECUTIONS_DELTA) AS PARSE_CALLS_AVG,
	ROUND(ss.PX_SERVERS_EXECS_DELTA  / ss.EXECUTIONS_DELTA) AS PX_SERVERS_EXECS_AVG
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where sql_id='&sqlid'
and hs.end_interval_time > sysdate - &daysago
order by hs.snap_id;


prompt Outros Delta values por hora AWR
select hs.snap_id, hs.instance_number, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,
	ss.IOWAIT_DELTA,
	ss.CLWAIT_DELTA,
	ss.APWAIT_DELTA,
	ss.CCWAIT_DELTA,
	ss.PLSEXEC_TIME_DELTA,
	ss.JAVEXEC_TIME_DELTA,
	ss.optimizer_mode,
	ss.parsing_schema_name
from dba_hist_snapshot hs
	inner join dba_hist_sqlstat ss
		on hs.snap_id = ss.snap_id
		and hs.instance_number = ss.instance_number	
where sql_id='&sqlid'
and hs.end_interval_time > sysdate - &daysago
order by hs.snap_id;