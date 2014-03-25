define dir_scripts=&1


connect SYS/change_on_install as SYSDBA
set echo on
spool &dir_scripts/JServer.log
@?/javavm/install/initjvm.sql;
@?/xdk/admin/initxml.sql;
@?/xdk/admin/xmlja.sql;
@?/rdbms/admin/catjava.sql;
spool off
exit;
