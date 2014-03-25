prompt % para todos
prompt 

define tablename=&tablename
define owner=&owner

col table_name format a30
col column_name format a20 word_wrapped
col owner format a30

SELECT cons.constraint_name, cols.column_name, cols.position, cons.status, cons.owner, cols.table_name
FROM dba_constraints cons, dba_cons_columns cols
WHERE cons.constraint_type = 'P'
AND cons.constraint_name = cols.constraint_name
AND cons.owner = cols.owner
and cons.owner like upper('&owner')
and cols.table_name like upper('&tablename')
ORDER BY cols.table_name, cols.position;

undef tablename
undef owner