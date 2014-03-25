col MACHINE for a35 justify left
col OSUSER for a20  justify left
col PROGRAM for a50  justify left
col USERNAME for a20 justify left
col STATUS for a10   justify left
col sid format 999999999
col event for a40
col sql_id for a14 justify right
col prev_sql_id for a14 justify right
col plan_hash_value for 9999999999999 justify right
col sql_hash_value for 9999999999999 justify right
col Idle_min for 9999999999999 justify right
col force_matching_signature for 99999999999999999999999999999999999

select a.sid,a.serial#,b.spid,a.username,w.event, last_call_et/60 Idle_min,a.sql_id, a.prev_sql_id, sq.force_matching_signature,  osuser,a.machine,a.program,a.status,logon_time,server, a.resource_consumer_group
from v$session a, v$process b, v$session_wait w, v$sql sq
where a.username is not null  
  and a.paddr = b.addr  
  and status = 'ACTIVE' 
  and a.sid = w.sid 
  and a.sid <> sys_context('userenv', 'sid')
  and sq.sql_id = a.sql_id
  and sq.child_number = a.SQL_CHILD_NUMBER
-- and sq.USERS_EXECUTING> 0
order by sq.force_matching_signature, Idle_min;
