prompt necessário informar o nome do owner e name de onde tem a mview
set long 99999
col QUERY_TXT format a9999 wrapped
prompt mview remotas registradas que usam local tables

define OWNER = &OWNER
define NAME = &NAME

SELECT QUERY_TXT
FROM DBA_REGISTERED_MVIEWS
WHERE OWNER = UPPER('&OWNER')
   AND NAME = UPPER('&NAME');
   
undef OWNER
undef NAME
