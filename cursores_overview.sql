
break on report skip 1 on inst_id skip 1 on sid skip 1 

prompt 
prompt ############## PARAMETRO ###################
col name for a100
col value for a100
select inst_id, name, value from gv$parameter where name like 'open_cursors';

col sql_text for a60
prompt 
prompt ############## STATUS AMBIENTE ###################
select distinct *
from (select c.inst_id, a.sid, a.machine,a.USERNAME,
		count(1) over(partition by c.inst_id, a.sid, a.machine,a.USERNAME) ctd_total, 
		c.sql_id,
		count(1) over(partition by c.inst_id, a.sid, a.machine,a.USERNAME, c.sql_id) ctd_sql_id, 
		c.sql_text
	from gv$session a, 
	     gv$process b,
	     gv$open_cursor c
	where 1=1 -- a.username is not null
	and a.paddr = b.addr
	and c.Saddr = a.Saddr
	and c.Sid = a.sid
	and a.inst_id = b.inst_id
	and a.inst_id = c.inst_id)
where ctd_total > 50
and ctd_sql_id > 10
order by inst_id, ctd_total desc, sid, ctd_sql_id desc;


clear computes
clear breaks