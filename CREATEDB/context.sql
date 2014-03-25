define dir_scripts=&1

connect SYS/change_on_install as SYSDBA
set echo on
spool &dir_scripts/context.log
@?/ctx/admin/dr0csys change_on_install DRSYS TEMPORARY;
connect CTXSYS/change_on_install
@?/ctx/admin/dr0inst /o01/app/oracle/product/9.2.0/lib/libctxx9.so;
@?/ctx/admin/defaults/dr0defin.sql AMERICAN;
spool off
exit;
