accept owner 	 prompt 'owner[all].........:' default 'all'
accept privilege prompt 'privilege[SEL].....:' default 'SELECT'

select TABLE_NAME,  GRANTOR, GRANTEE, PRIVILEGE
from dba_tab_privs
where OWNER='&owner'
and PRIVILEGE like '&privilege'
order by GRANTEE, TABLE_NAME;

select &owner, &privilege from dual;

undef owner;
undef privilege;