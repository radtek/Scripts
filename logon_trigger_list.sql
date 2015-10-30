select owner, trigger_name, status, trigger_body, BASE_OBJECT_TYPE
from dba_triggers 
where owner like upper('&owner') 
and TRIGGERING_EVENT like '%LOGON%';