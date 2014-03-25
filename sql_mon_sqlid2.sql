col sid for 999999
select SQL_EXEC_START, SQL_EXEC_ID, SQL_PLAN_HASH_VALUE, SID, PROCESS_NAME from v$sql_monitor where sql_id = '&sqlid';
