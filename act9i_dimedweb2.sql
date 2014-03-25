col MACHINE for a30
col OSUSER for a20
col PROGRAM for a50
col USERNAME for a20
col STATUS for a10
col sid format 999999999
col event for a40
select a.sid,a.serial#,b.spid,a.username,last_call_et/60 "Idle - min",w.event, a.sql_hash_value,  osuser,a.machine,a.program,a.status,logon_time,server
from v$session a
	left join v$process b
		on a.paddr = b.addr
	left join v$session_wait w
		on a.sid = w.sid
where a.username like upper('DIMEDWEB')
  and a.status = 'ACTIVE'
order by "Idle - min" desc, a.username, a.status;