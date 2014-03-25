prompt gera script das fk que dependem da tabela X
set lines 2000
set pages 0
set long 200000
set feedback off
col DDL format a9999
define owner=&owner
define table_name=&table_name

select 
	dbms_metadata.get_ddl('REF_CONSTRAINT',  constraint_name, owner) AS DDL 
from dba_constraints
where (r_owner, r_constraint_name) in (select owner, constraint_name
                                   from dba_constraints
                                   where owner = upper('&owner')
                                   and TABLE_NAME = upper('&table_name'))	
and constraint_type = 'R';

set pages 2000
set feedback on

select 
	constraint_name, owner, TABLE_NAME
from dba_constraints
where (r_owner, r_constraint_name) in (select owner, constraint_name
                                   from dba_constraints
                                   where owner = upper('&owner')
                                   and TABLE_NAME = upper('&table_name'))	
and constraint_type = 'R';

undefine owner
undefine table_name

