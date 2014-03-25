-- Gera qualquer tipo de Objeto
accept sch prompt 'Owner......:'
accept typ prompt 'Object_type:'
accept nam Prompt 'Object_name:'

set pagesize 0
set long 200000;
set feedback off

col DDL format a9999

select dbms_metadata.get_ddl (upper(replace('&typ', ' ', '_')) ,  upper('&nam'), upper('&sch')) AS DDL from dual;
  
set pagesize 20
set feedback on