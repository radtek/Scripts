select executions, elapsed_time, USERS_EXECUTING, round((elapsed_time / executions) / 1000) as avg_elapsed
from v$sql 
where sql_id = '2p0bq3hbh2mcn';

select a.sid,a.serial#,b.spid,a.username,w.event, last_call_et/60 Idle_min,a.sql_id, a.prev_sql_id, sq.force_matching_signature,  osuser,a.machine,a.program,a.status,logon_time,server, a.resource_consumer_group
from v$session a, v$process b, v$session_wait w, v$sql sq
where a.username is not null
  and a.paddr = b.addr
  and status = 'ACTIVE'
  and a.sid = w.sid
  and sq.sql_id = '2p0bq3hbh2mcn'
  and sq.sql_id = a.sql_id
  and sq.child_number = a.SQL_CHILD_NUMBER
-- and sq.USERS_EXECUTING> 0
order by sq.force_matching_signature, Idle_min
/
