define dir_scripts=&1
connect SYS/change_on_install as SYSDBA
set echo on
spool &dir_scripts/ordinst.log
@?/ord/admin/ordinst.sql;
spool off
exit;
