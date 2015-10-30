prompt *************************************
prompt 	Possivel também usar:
prompt 		commit|rollback force 'local_tran_id'
prompt *************************************
select 
LOCAL_TRAN_ID,
GLOBAL_TRAN_ID,
STATE,
MIXED,
ADVICE,
TRAN_COMMENT,
FAIL_TIME,
FORCE_TIME,
RETRY_TIME,
OS_USER,
OS_TERMINAL,
HOST,
DB_USER,
COMMIT#
from DBA_2PC_PENDING;

select OS_TERMINAL, OS_USER, 'exec DBMS_TRANSACTION.purge_lost_db_entry('''||LOCAL_TRAN_ID||''');'||chr(10)||'commit;' from DBA_2PC_PENDING;