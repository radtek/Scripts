select owner, trigger_name, status, trigger_body 
from dba_triggers 
where owner like upper('&owner') 
and TRIGGERING_EVENT like '%LOGON%';