


column temp_mb format 99999999
column sample_time format a25 
prompt
prompt DBA_HIST_ACTIVE_SESS_HISTORY
prompt  
 select sample_time,session_id,session_serial#,sql_id,temp_space_allocated/1024/1024 temp_mb, 
 temp_space_allocated/1024/1024-lag(temp_space_allocated/1024/1024,1,0) over (order by sample_time) as temp_diff
 from dba_hist_active_sess_history 
 --from v$active_session_history
 where 
 session_id=&1 
 and session_serial#=&2
 order by sample_time asc
 /
prompt
prompt ACTIVE_SESS_HIST
prompt 
 select sample_time,session_id,session_serial#,sql_id,temp_space_allocated/1024/1024 temp_mb, 
 temp_space_allocated/1024/1024-lag(temp_space_allocated/1024/1024,1,0) over (order by sample_time) as temp_diff
 --from dba_hist_active_sess_history 
 from v$active_session_history
 where 
 session_id=&1 
 and session_serial#=&2
 order by sample_time asc
 /



