select log_owner, master, log_table, rowids, primary_key
FROM DBA_MVIEW_LOGS
where log_owner like upper('&log_owner')
and master like upper('&master');