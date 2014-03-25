prompt **** 
prompt **** Mesmo que @objinv, porém recebe uma lista de parametros 
prompt **** 

select owner||'.'||object_name "OBJECT",object_type TYPE,LAST_DDL_TIME
from dba_objects
where status = 'INVALID'
and owner in (&OWNER)
order by 1;