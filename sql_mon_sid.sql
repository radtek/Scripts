col sid for 999999
select SQL_EXEC_START, SQL_EXEC_ID, SQL_PLAN_HASH_VALUE, SID, PROCESS_NAME, sql_id from v$sql_monitor where sid = &sid
order by SQL_EXEC_START;