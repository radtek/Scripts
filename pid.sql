select s.machine, s.osuser,s.sid,s.username,s.sql_hash_value, s.status
from v$session s, v$process p
where s.paddr = p.addr
       and p.spid = &pid
/
