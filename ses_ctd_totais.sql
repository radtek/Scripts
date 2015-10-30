break on inst_id skip 1

compute sum of ctd on inst_id


prompt ########## POR MACHINEX USER ###############
select inst_id, username, server, machine, count(1) ctd
from gv$session 
group by inst_id, server, machine, username
order by 1,2,3,4,5 desc;

prompt 
prompt 
prompt ########## POR MACHINE ###############
select inst_id, machine, server, count(1) ctd
from gv$session 
group by inst_id, server, machine
order by 1,2,3,4 desc;

prompt 
prompt 
prompt ########## POR USER ###############
select inst_id, username, server, count(1) ctd
from gv$session 
group by inst_id, server, username
order by 1,2,3,4 desc;

clear breaks