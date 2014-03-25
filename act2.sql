col MACHINE for a30 
col OSUSER for a20 
col PROGRAM for a50 
col USERNAME for a20 
col STATUS for a10 
col sid format 999999999
col event for a40
col sql_id for a14 justify right
col prev_sql_id for a14 justify right
col plan_hash_value for 9999999999999 justify right
col sql_hash_value for 9999999999999 justify right
col Idle_min for 9999999999999 justify right

select a.sid,a.serial#,b.spid,a.username,w.event, last_call_et/60 Idle_min,a.sql_id, a.prev_sql_id, sq.plan_hash_value, a.sql_hash_value, osuser,a.machine,a.program,a.status,logon_time,server
from v$session a	
	inner join v$process b
		ON a.paddr = b.addr  
	inner join v$session_wait w
		ON a.sid = w.sid 
	inner join v$sql sq
		ON sq.sql_id = a.sql_id
		and sq.child_number = a.SQL_CHILD_NUMBER 
where a.username is not null  
  and status = 'ACTIVE' 
  and a.sid <> sys_context('userenv', 'sid')
order by 5;