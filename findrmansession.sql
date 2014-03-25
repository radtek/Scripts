select sid, spid, client_info 
from v$process p join v$session s on (p.addr = s.paddr) 
where client_info like '%rman%' or 
client_info like '%id=%';