define dir_scripts=&1

connect SYS/change_on_install as SYSDBA
set echo Off
spool &dir_scripts/CreateDBCatalog.log
@?/rdbms/admin/catalog.sql;
@?/rdbms/admin/catexp7.sql;
@?/rdbms/admin/catblock.sql;
@?/rdbms/admin/catproc.sql;
@?/rdbms/admin/catoctk.sql;
@?/rdbms/admin/owminst.plb;
connect SYSTEM/manager
@?/sqlplus/admin/pupbld.sql;
connect SYSTEM/manager
set echo on
spool &dir_scripts/sqlPlusHelp.log
@?/sqlplus/admin/help/hlpbld.sql helpus.sql;
spool off
spool off
exit;
