 select s.username,s.machine,p.spid
from v$session s, v$process p
where s.paddr =p.addr
and sid = &sid
/
