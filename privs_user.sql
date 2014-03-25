define username = &username
select * from dba_tab_privs where upper(grantee) = upper('&username');
select * from dba_sys_privs where upper(grantee) = upper('&username');
select * from dba_role_privs where upper(grantee) = upper('&username');
@@tbs_quota
undef username