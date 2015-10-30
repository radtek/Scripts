prompt executar em mount
SELECT
	MIN(checkpoint_change#) start_scn,
	GREATEST(MAX(checkpoint_change#),MAX(absolute_fuzzy_change#)) beyond_scn
FROM v$backup_datafile
WHERE incremental_level=(SELECT MAX(incremental_level) FROM v$backup_datafile WHERE incremental_level>=0);