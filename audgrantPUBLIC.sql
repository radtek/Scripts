select distinct 
   owner,
   table_name, 
   privilege, 
   grantor
from 
   sys.dba_tab_privs
where 
   grantee = 'PUBLIC'
and
   owner not in (‘SYS’,’SYSTEM’);

