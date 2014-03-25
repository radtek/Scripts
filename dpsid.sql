select 
   sid, 
   serial#
from 
   v$session s, 
   dba_datapump_sessions d
where 
   s.saddr = d.saddr;