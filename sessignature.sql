col EVENT for a30
col WAIT_CLASS for a30

prompt 
SELECT /*+ leading(s) */
s.sid db_sid
,s.serial# db_serial
,p.spid os_pid
, s.sql_id
, prev_sql_id
,last_call_et/60 Idle_min
,to_char(s.logon_time, 'YYYY/MM/DD HH24:MI:SS') db_logon_time
,nvl(s.username, 'SYS') db_user
,s.osuser os_user
,s.machine os_machine
,nvl(decode(instr(s.terminal, chr(0))
,0
,s.terminal
,substr(s.terminal, 1, instr(s.terminal, chr(0))-1)),'none') os_terminal
,s.program os_program,
s.server,
round(PGA_USED_MEM  / 1024 / 1024, 2) as PGA_USED_MEM_MB, 
round(PGA_ALLOC_MEM / 1024 / 1024, 2) AS PGA_ALLOC_MEM_MB, 
round(PGA_MAX_MEM   / 1024 / 1024, 2) as PGA_MAX_MEM_MB
,s.status
,s.BLOCKING_SESSION
,s.BLOCKING_INSTANCE,
s.EVENT, s.WAIT_CLASS
from
	v$session s
	,v$process p
	,v$sql sq
where 1=1
and s.paddr = p.addr
and s.sql_id = sq.sql_id
and sq.child_number = s.SQL_CHILD_NUMBER
and upper(s.username) like upper('&username')
and sq.force_matching_signature = &force_matching_signature
order by Idle_min, s.username;


