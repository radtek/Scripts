define username=&username
select * from dba_tab_privs where owner like upper('&username');
select * from dba_sys_privs where PRIVILEGE like upper('%SELECT%ANY%') order by PRIVILEGE;
undef username