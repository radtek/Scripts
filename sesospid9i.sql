prompt 
SELECT
s.sid db_sid
,s.serial# db_serial
,p.spid os_pid
,to_char(s.logon_time, 'YYYY/MM/DD HH24:MI:SS') db_logon_time
,nvl(s.username, 'SYS') db_user
,s.osuser os_user
,s.SQL_HASH_VALUE
,s.PREV_HASH_VALUE
,s.machine os_machine
,nvl(decode(instr(s.terminal, chr(0))
,0
,s.terminal
,substr(s.terminal, 1, instr(s.terminal, chr(0))-1)),'none') os_terminal
,p.program os_program
,s.program s_program
,s.status
from
	v$session s
	,v$process p
where 1=1
and s.paddr = p.addr
and p.spid = &os_pid;