prompt *** informe inst_id ou 0 para todos
prompt
define inst_id= &inst_id
define machine= &machine
define username= &username

col OS_MACHINE format a30
col OS_USER format a20
col OS_TERMINAL format a20
col OS_PROGRAM format a20
col SERVER format a10
col INSTANCE_NAME format a15
col host_name format a30

SELECT
i.instance_name, 
s.sid db_sid
,s.serial# db_serial
,p.spid os_pid
,s.sql_id
,s.prev_sql_id
,to_char(s.logon_time, 'YYYY/MM/DD HH24:MI:SS') db_logon_time
,nvl(s.username, 'SYS') db_user
,s.osuser os_user
,s.machine os_machine
,nvl(decode(instr(s.terminal, chr(0))
,0
,s.terminal
,substr(s.terminal, 1, instr(s.terminal, chr(0))-1)),'none') os_terminal
,s.program os_program,
s.SERVER AS SERVER,
round(PGA_USED_MEM  / 1024 / 1024, 2) as PGA_USED_MEM_MB,
round(PGA_ALLOC_MEM / 1024 / 1024, 2) AS PGA_ALLOC_MEM_MB,
round(PGA_MAX_MEM   / 1024 / 1024, 2) as PGA_MAX_MEM_MB, 
S.status, 
i.host_name
from
gv$session s
,gv$process p, 
gv$instance i
where 1=1
and s.paddr = p.addr
and s.inst_id = p.inst_id
and i.inst_id = s.inst_id
and upper(s.machine) like upper('&&machine')
and (s.inst_id = &&inst_id or &&inst_id = 0)
and (s.username like upper('&&username'))
order by 1, s.logon_time;

undefine inst_id
undef machine
undef username