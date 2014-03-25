col object for a60
col type for a30
select owner||'.'||object_name "OBJECT",object_type TYPE,LAST_DDL_TIME
from dba_objects
where status = 'INVALID'
and owner like UPPER('&OWNER')
order by 1;