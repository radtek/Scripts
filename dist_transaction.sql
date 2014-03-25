col local_tran_id for a15
col GLOBAL_TRAN_ID for a55
col OS_USER for a15
col OS_TERMINAL for a15
col HOST for a20
col DB_USER for a15

select local_tran_id, GLOBAL_TRAN_ID,STATE,FAIL_TIME,OS_USER,OS_TERMINAL,HOST,DB_USER from dba_2pc_pending order by fail_time;