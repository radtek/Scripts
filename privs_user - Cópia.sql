define username = &username
select * from dba_tab_privs where upper(owner) = upper('&username');
undef username