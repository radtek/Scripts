col object_name for a70
select owner, object_name, object_type, status,LAST_DDL_TIME , CREATED
from dba_objects
where owner like upper('&owner') and
object_name like upper('&object')
order by LAST_DDL_TIME;
undef owner
undef object