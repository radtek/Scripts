select *
from v$process_memory
where  pid = (select pid
from v$process
where addr = (select paddr
from v$session
where sid = &sid))
/
