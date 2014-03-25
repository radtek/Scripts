define dir_scripts=&1

connect SYS/change_on_install as SYSDBA
set echo on
spool &dir_scripts/postDBCreation.log
@?/rdbms/admin/utlrp.sql;
shutdown immediate;
connect SYS/change_on_install as SYSDBA
startup ;
exit;
