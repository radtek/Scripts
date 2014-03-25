set pages 2000
set lines 2000
define sqlid=&sqlid

var max_snap number

begin
	select max(snap_id) into :max_snap from dba_hist_snapshot;
end;
/


select
  round(s.elapsed_time_delta / s.EXECUTIONS_DELTA) AS avg_elapsed,
  round(s.buffer_gets_delta  / s.EXECUTIONS_DELTA) AS avg_buffer_gets,
  round(s.disk_reads_delta  / s.EXECUTIONS_DELTA) AS avg_disk_reads,
  round(s.ROWS_PROCESSED_DELTA  / s.EXECUTIONS_DELTA) AS avg_rows,
  round(s.CPU_TIME_DELTA  / s.EXECUTIONS_DELTA) AS avg_cpu  
from
  dba_hist_sqltext t,
  dba_hist_sqlstat s
where
  t.dbid = s.dbid
  and t.sql_id = s.sql_id
  and s.snap_id between :max_snap-2 and :max_snap
  and t.sql_id = '&sqlid'
  and s.EXECUTIONS_DELTA > 0;
 
select * from table(dbms_xplan.display_awr('&sqlid', null, null, 'ALL ALLSTATS LAST'));

undef sqlid