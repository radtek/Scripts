define dir_scripts=&1

connect SYS/change_on_install as SYSDBA
set echo on
spool &dir_scripts/xdb_protocol.log
@?/rdbms/admin/catqm.sql change_on_install XDB TEMPORARY;
connect SYS/change_on_install as SYSDBA
@?/rdbms/admin/catxdbj.sql;
spool off
exit;
