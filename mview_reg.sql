prompt necessário informar o nome do owner e name de onde tem a mview
col MVIEW_SITE format a30
prompt mview remotas registradas que usam local tables

define OWNER = &OWNER
define NAME = &NAME

SELECT OWNER, NAME, MVIEW_SITE, CAN_USE_LOG, UPDATABLE, REFRESH_METHOD, MVIEW_ID
FROM DBA_REGISTERED_MVIEWS
WHERE OWNER like UPPER('&OWNER')
   AND NAME like UPPER('&NAME');
   
undef OWNER
undef NAME
