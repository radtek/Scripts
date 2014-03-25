SELECT
i.instance_name,
s.SERVER, 
nvl(s.username, 'SYS') db_user,
count(1)
from
gv$session s
,gv$process p,
gv$instance i
where 1=1
and s.paddr = p.addr
and s.inst_id = p.inst_id
and i.inst_id = s.inst_id
and upper(s.machine) like upper('&hostname')
group by i.instance_name,
s.SERVER,
nvl(s.username, 'SYS')
order by 1
/
