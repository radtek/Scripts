SELECT
i.instance_name,
s.sid db_sid
,s.serial# db_serial
,s.status 
, s.state
, s.event
,p.spid os_pid
,to_char(s.logon_time, 'YYYY/MM/DD HH24:MI:SS') db_logon_time
,nvl(s.username, 'SYS') db_user
,s.osuser os_user
,s.machine os_machine
,nvl(decode(instr(s.terminal, chr(0))
,0
,s.terminal
,substr(s.terminal, 1, instr(s.terminal, chr(0))-1)),'none') os_terminal
,s.program os_program
,s.SERVER
,s.status
,i.host_name
from
v$session s
,v$process p
,v$instance i
where 1=1
and s.paddr = p.addr
and s.username like upper('&username')
order by 1, s.SERVER
/
