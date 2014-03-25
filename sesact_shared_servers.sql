SELECT p.spid ses_spid,
	tbl.sid ses_sid, 
	tbl.ssw_spid,
	tbl.ss_spid, 
	tbl.waiter,
	tbl.server
	, sql_id
	, prev_sql_id
	,to_char(s.logon_time, 'YYYY/MM/DD HH24:MI:SS') db_logon_time
	,s.status
	,nvl(s.username, 'SYS') db_user
	,s.osuser os_user
	,s.machine os_machine
	,nvl(decode(instr(s.terminal, chr(0))
	,0
	,s.terminal
	,substr(s.terminal, 1, instr(s.terminal, chr(0))-1)),'none') os_terminal
	,s.program os_program
from
   v$session s
	inner join V$process p
		on s.paddr = p.addr
	inner JOIn (
		select 
			(select s.sid 
			from v$process p 				
				inner join v$session s 
				  on s.paddr = p.addr
			where c.SADDR = s.SADDR or c.SADDR = s.PADDR) as sid,
		       (select spid 
			from v$process p 
			where c.WAITER = p.ADDR ) ssw_spid,
       			(select p.spid 
			from v$process p 
			where c.SERVER = p.ADDR ) ss_spid,
			c.SERVER,
			c.WAITER
		from v$circuit c
		where c.SERVER <> '00' or 
		      c.WAITER <> '00') tbl
		ON s.sid = tbl.sid;