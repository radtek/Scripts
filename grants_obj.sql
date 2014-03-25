select 'GRANT ' || PRIVILEGE ||' ON ' || OWNER || '.' || TABLE_NAME || ' TO ' || GRANTEE || ';'
from dba_tab_privs
where OWNER = upper('&OWNER')
and TABLE_NAME = upper('&table_name')
/
