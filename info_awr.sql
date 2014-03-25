Accept sqlid    Prompt 'Sql_id..:'

spool info_awr_&sqlid..lst

Select Min(Snap_id), Max(snap_id), Count(*) Nro_ocorrencias, Count(Distinct Plan_hash_value) Nro_planos_distintos
  from dba_hist_sqlstat
 where sql_id = '&sqlid';


Accept snap_ini Prompt 'Snap_ini:'
Accept snap_fin Prompt 'Snap_fin:'

Select *
from dba_hist_snapshot
where snap_id In (&Snap_ini,&snap_fin)
Order by instance_number, snap_id;

col end_time for a35
Break On Instance_number skip 1;

Select A.INSTANCE_NUMBER, A.snap_id, B.End_interval_time End_time, A.PLAN_HASH_VALUE,
	   Round(Round(BUFFER_GETS_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL))) Buff_Exec,
	   Round(ROWS_PROCESSED_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL)) rows_exec,
	   Round((ELAPSED_TIME_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL)/1000000),2) Elapsed_exec_s,
	   Round((CPU_TIME_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL)/1000000),2) cpu_exec_s,
           Round(DISK_READS_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL),2) Disk_exec,
           A.EXECUTIONS_DELTA,
           EXECUTIONS_TOTAL exec_total,
           BUFFER_GETS_TOTAL Buff_total,
           ROWS_PROCESSED_TOTAL Rows_total,
           CPU_TIME_TOTAL,
           ELAPSED_TIME_TOTAL,
           DISK_READS_TOTAL,
           Round(((IOWAIT_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL))/1000000),2) iow_exec_s          ,
           Round(((CLWAIT_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL))/1000000),2) clw_exec_s          ,
           Round(((APWAIT_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL))/1000000),2) apw_exec_s          ,
           Round(((CCWAIT_TOTAL / Decode(EXECUTIONS_TOTAL,0,1,EXECUTIONS_TOTAL))/1000000),2) ccw_exec_s          ,
           A.Version_count,
           END_OF_FETCH_COUNT_TOTAL
  from DBA_HIST_SQLSTAT A, dba_hist_snapshot B
 where A.sql_id = '&sqlid'
   and A.snap_id between &Snap_ini and &snap_fin
   and a.snap_id = b.snap_id
   and a.instance_number = b.instance_number
--   and a.executions_delta >0
 Order by instance_number, snap_id;

SELECT *
FROM  TABLE(DBMS_XPLAN.DISPLAY_AWR('&sqlid'));

col VALUE_STRING for a20
Select * from (
Select SNAP_ID, INSTANCE_NUMBER, NAME, POSITION, DATATYPE_STRING, VALUE_STRING
from DBA_HIST_SQLBIND A
 where A.sql_id = '&sqlid'
   and snap_id between &Snap_ini and &snap_fin
 Order by instance_number, snap_id, position)
where rownum <= 50;


Select sql_text
  from DBA_HIST_SQLTEXT
 where sql_id = '&sqlid'
/

spool off;
