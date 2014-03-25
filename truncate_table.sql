prompt REM desabilita contraints ativas -> trunca todas tabelas do owner -> reativa contraints que estavam ativadas
set pages 0
set feedback off
set verify off
define owner = &owner

SELECT 'ALTER TABLE ' || owner || '.' || TABLE_NAME || ' DISABLE CONSTRAINT ' || CONSTRAINT_NAME || ';'
from dba_constraints 
where owner = upper('&owner')
and constraint_type = 'R'
and status = 'ENABLED';

select 'TRUNCATE TABLE ' || owner || '.' || table_name || ';'
 from dba_tables 
where owner = upper('&owner');


SELECT 'ALTER TABLE ' || owner || '.' || TABLE_NAME || ' ENABLE CONSTRAINT ' || CONSTRAINT_NAME || ';'
from dba_constraints 
where owner = upper('&owner')
and constraint_type = 'R'
and status = 'ENABLED';

undefine owner
set pages 100
set feedback on 
set verify on