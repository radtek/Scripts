select a.sid,a.serial#,b.spid,a.username,w.event, last_call_et/60 Idle_min,a.sql_id, a.prev_sql_id, sq.force_matching_signature,  osuser,a.machine,a.program,a.status,logon_time,server, a.resource_consumer_group
from v$session a, v$process b, v$session_wait w, v$sql sq
where a.username is not null
  and a.paddr = b.addr
  and status = 'ACTIVE'
  and a.sid = w.sid
  and a.sid <> sys_context('userenv', 'sid')
  and sq.sql_id = a.sql_id
  and a.machine = 'APISUL\NB518206'
  and sq.child_number = a.SQL_CHILD_NUMBER
-- and sq.USERS_EXECUTING> 0
order by sq.force_matching_signature, Idle_min
/
