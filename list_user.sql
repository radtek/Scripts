col username format a20
col account_status format a20
col profile format a20
col default_tablespace format a30
col temporary_tablespace format a30
select username, account_status, profile, default_tablespace, temporary_tablespace, lock_date, CREATED, INITIAL_RSRC_CONSUMER_GROUP
from dba_users where username like UPPER('%&username%');