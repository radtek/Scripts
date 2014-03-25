define owner = &owner
define TABLE_NAME = &TABLE_NAME

select owner, constraint_name, constraint_type, table_name, status, last_change, invalid 
from dba_constraints 
where (r_owner, r_constraint_name) in (select owner, constraint_name
					from dba_constraints 
					where owner = '&OWNER'
					and TABLE_NAME = '&TABLE_NAME')
order by 1, 2;

-- objetos que ela depende
select owner, name, type, referenced_link_name, dependency_type
from dba_dependencies
where referenced_name = upper('&TABLE_NAME')
and referenced_owner = upper('&owner')
order by 1, 2;

-- objetos que depende dela
select owner, name, type, referenced_link_name, dependency_type
from dba_dependencies
where owner = upper('&TABLE_NAME')
and name = upper('&owner')
order by 1, 2;

undef owner
undef TABLE_NAME