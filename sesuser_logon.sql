prompt *** informe inst_id ou 0 pa2ra todos
prompt
define inst_id = &inst_id
col OS_MACHINE format a30
col OS_USER format a20
col OS_TERMINAL format a20
col OS_PROGRAM format a20
col SERVER format a10
col SERVER format a10
col INSTANCE_NAME format a15
col host_name format a30
col os_pid format a9 

SELECT
i.instance_name, 
s.sid db_sid
,s.serial# db_serial
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
,s.module
,s.ACTION
,s.CLIENT_INFO
,s.sql_id
from
gv$session s
,gv$process p
,gv$instance i
where 1=1
and s.pa2ddr = p.addr
and s.inst_id = p.inst_id
and i.inst_id = s.inst_id
and s.username like upper('&user')
and (s.inst_id = &inst_id or &inst_id = 0)
order by db_logon_time;

undefine inst_id