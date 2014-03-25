prompt 20 tops 
prompt Informe a coluna para ordenamento:
prompt 6 - block_gets
prompt 7 - CONSISTENT_GETS
prompt 8 - PHYSICAL_READS
prompt 9 - BLOCK_CHANGES
accept order prompt "Informe o numero:"
define sid=&sid

COL machine for A25 
col sid for 9999999999

select * from 
(select a.sid,b.spid,a.machine, a.username, a.program, 
	c.block_gets, c.CONSISTENT_GETS, c.PHYSICAL_READS, c.BLOCK_CHANGES
from v$session a, v$process b, v$sess_io c 
where (a.sid = &sid or &sid = 0)
and a.paddr = b.addr 
and a.sid = c.sid 
order by &order desc) where rownum <= 20; 

undef sid
undef order