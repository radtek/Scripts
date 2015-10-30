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
col spid for 999999999

select a.sid,a.serial#,b.spid,a.username,w.event, a.SEQ#, last_call_et/60 Idle_min,a.sql_id, a.prev_sql_id, a.sql_hash_value,  osuser,a.machine,a.program,a.status,logon_time,server, a.resource_consumer_group, a.SEQ#
from v$session a, v$process b, v$session_wait w
where a.username is not null  
  and a.paddr = b.addr  
  and status = 'ACTIVE' 
  and a.sid = w.sid 
  and a.sid <> sys_context('userenv', 'sid')
order by a.username, Idle_min;
