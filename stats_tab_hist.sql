select owner, table_name, PARTITION_NAME, STATS_UPDATE_TIME 
						from DBA_TAB_STATS_HISTORY 
						where owner like upper('&owner') 
						  and table_name like upper('&table_name')
						order by STATS_UPDATE_TIME;