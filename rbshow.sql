
accept owner prompt "informe o owner ou NULL para todos: " default 'NULL'

select droptime, owner, object_name, original_name, 
	type, ts_name, can_undrop 
from dba_recyclebin
where owner = upper('&owner') or upper('&owner') = 'NULL'
order by owner, droptime DESC;

undef owner