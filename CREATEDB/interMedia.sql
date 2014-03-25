define dir_scripts=&1

connect SYS/change_on_install as SYSDBA
set echo on
spool &dir_scripts/interMedia.log
@?/ord/im/admin/iminst.sql;
spool off
exit;
