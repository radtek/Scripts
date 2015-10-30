set long 99999999
set linesize 32000
set pages 0
--prompt parametros:
--prompt 		partitioning = true | false

def owner=UPPER('&owner')
def tablename=UPPER('&tablename')
--def partitioning=&partitioning

col DDL format a9999

-- configure
EXEC dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS_AS_ALTER', TRUE );
EXEC dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false ); 
EXEC dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true ); 

-- terminator
EXEC dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE );
-- table
SELECT DBMS_METADATA.GET_DDL('TABLE', &tablename, &owner) AS DDL FROM DUAL;
-- gera grants
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('OBJECT_GRANT', &tablename, &owner) AS DDL FROM DUAL;
-- gera ref constraints , já pega no create table
--SELECT DBMS_METADATA.GET_DEPENDENT_DDL('REF_CONSTRAINT', &tablename, &owner) AS DDL FROM DUAL;
-- gera constraints pk, uk, ck, já pega no create table
--SELECT DBMS_METADATA.GET_DEPENDENT_DDL('CONSTRAINT', &tablename, &owner) AS DDL FROM DUAL;
-- get trigger
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('TRIGGER', &tablename, &owner) AS DDL FROM DUAL;
-- get indexes
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('INDEX', &tablename, &owner) AS DDL FROM DUAL;
-- comment
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('COMMENT', &tablename, &owner) AS DDL FROM DUAL;
-- mview log
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('MATERIALIZED_VIEW_LOG', &tablename, &owner) AS DDL FROM DUAL;
-- mview
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('MATERIALIZED_VIEW', &tablename, &owner) AS DDL FROM DUAL;

set pages 200

select constraint_name, constraint_type, status, validated 
from dba_constraints 
where owner= &owner
and table_name = &tablename;


undef tablename
undef owner
undef partitioning

