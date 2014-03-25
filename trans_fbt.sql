prompt requisitos:
prompt - alter database add supplemental log data;
					
prompt - alter database add supplemental log data (primary key) columns;
prompt 
select start_scn, commit_scn, logon_user, 
	operation, table_name, undo_sql 
from flashback_transaction_query 
where xid = hextoraw('&xid')
/