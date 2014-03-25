define USER=&usuario
set long 1000000
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
select dbms_metadata.get_ddl('USER','&&USER') from dual;
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT','&&USER') from dual;
select dbms_metadata.get_granted_ddl('OBJECT_GRANT','&&USER') from dual;
select dbms_metadata.get_granted_ddl('ROLE_GRANT','&&USER') from dual;