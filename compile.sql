undef owner
define owner = &owner

select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)
||' '||owner||'."'||object_name||'" compile '||
decode(object_type,'PACKAGE BODY','BODY;',';')
from dba_objects
where status = 'INVALID' and 
      owner like upper('&owner')
order by object_type desc;

select 'desc ' || s.owner || '.' ||s.SYNONYM_NAME
from dba_synonyms s
    inner join dba_objects o
      on o.OBJECT_NAME=s.SYNONYM_NAME
      and o.OWNER = s.OWNER
where o.status = 'INVALID'
and o.owner like upper('&owner');

undef owner