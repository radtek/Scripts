
select xmltype(binds_xml), sql_id
from v$sql_monitor 
where sid = &sid 
and status = 'EXECUTING';

undef sid 