set long 99999999
set linesize 32000
set pages 0

def owner=UPPER('&owner')

select dbms_metadata.get_granted_ddl('SYSTEM_GRANT',&owner) DDL from dual;
select dbms_metadata.get_granted_ddl('ROLE_GRANT',&owner) DDL from dual;
select dbms_metadata.get_granted_ddl('OBJECT_GRANT',&owner) DDL from dual;

undef owner