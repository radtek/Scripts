column flashback_archive_name format a15;

select flashback_archive_name, flashback_archive#, retention_in_days, status 
						from dba_flashback_archive;
						
						select * from dba_flashback_archive_ts;

select table_name, owner_name, FLASHBACK_ARCHIVE_NAME, ARCHIVE_TABLE_NAME, STATUS 
					FROM DBA_FLASHBACK_ARCHIVE_TABLES;
/