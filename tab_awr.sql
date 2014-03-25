Accept dt1  		prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  		prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
Accept inst 		prompt 'Instance Number..............:'
Accept owner  		prompt 'Owner........................:'
Accept object_name  prompt 'Object_name..................:'

col "Tablespace" for a40
prompt
prompt *************** TOTAL VALUES ***************************
prompt *************** ESTATISTICAS DE HARDWARE *************** 
prompt
SELECT  hs.snap_id as "id", 
		to_char(HS.end_interval_time, 'DD/MM HH24:MI') AS "Interval",
		SUM(LOGICAL_READS_TOTAL) AS "LogicalReads", 
		SUM(BUFFER_BUSY_WAITS_TOTAL) AS "BufferBusyWaits", 
		SUM(DB_BLOCK_CHANGES_TOTAL) AS "BlockChanges",
		 SUM(PHYSICAL_READS_TOTAL) AS "PhyReads", 
		 SUM(PHYSICAL_WRITES_TOTAL) AS "PhyWrites", 
		 SUM(PHYSICAL_READS_DIRECT_TOTAL) AS "DirectReads",  
		 SUM(PHYSICAL_WRITES_DIRECT_TOTAL) AS "DirectWrites",  
		 SO.TABLESPACE_NAME AS "Tablespace"
FROM DBA_HIST_SEG_STAT_OBJ SO
	 INNER JOIN DBA_HIST_SEG_STAT SS
		ON SO.DBID = SS.DBID
		 AND SO.TS# = SS.TS#
		 AND SO.OBJ# = SS.OBJ#
		 AND SO.DATAOBJ# = SS.DATAOBJ#
	 INNER JOIN DBA_HIST_SNAPSHOT HS
		ON HS.SNAP_ID = SS.SNAP_ID 
		AND HS.INSTANCE_NUMBER = SS.INSTANCE_NUMBER
WHERE HS.END_INTERVAL_TIME BETWEEN TO_DATE('&dt1', 'DD/MM/YYYY HH:MI:SS') AND TO_DATE('&dt2', 'DD/MM/YYYY HH:MI:SS')
 AND (HS.INSTANCE_NUMBER = &inst OR &inst = 0)
 AND SO.OBJECT_NAME = upper('&object_name')
 AND SO.OWNER = upper('&owner')
 GROUP BY HS.end_interval_time, hs.snap_id, SO.TABLESPACE_NAME
 ORDER BY 1;
 

prompt 
prompt *************** TOTAL VALUES ***************************
prompt *************** ESTATISTICAS DE GC + LOCKS *************** 
prompt  
SELECT hs.snap_id as "id", 
		to_char(HS.end_interval_time, 'DD/MM HH24:MI') AS "Interval",
		SUM(ITL_WAITS_TOTAL) AS "ITLWaits", 
		SUM(ROW_LOCK_WAITS_TOTAL) as "RowLockWaits", 
		SUM(GC_CR_BLOCKS_SERVED_TOTAL) AS "GC_CR_Blocks_Snd", 
		SUM(GC_CU_BLOCKS_SERVED_TOTAL) AS "GC_CU_Blocks_Snd", 
		SUM(GC_BUFFER_BUSY_TOTAL)  AS "GC_BufferBusy", 
		SUM(GC_CR_BLOCKS_RECEIVED_TOTAL) AS "GC_CR_Blocks_Rcv", 
		SUM(GC_CU_BLOCKS_RECEIVED_TOTAL)  AS "GC_CU_Blocks_Rcv"
FROM DBA_HIST_SEG_STAT_OBJ SO
	 INNER JOIN DBA_HIST_SEG_STAT SS
		ON SO.DBID = SS.DBID
		 AND SO.TS# = SS.TS#
		 AND SO.OBJ# = SS.OBJ#
		 AND SO.DATAOBJ# = SS.DATAOBJ#
	 INNER JOIN DBA_HIST_SNAPSHOT HS
		ON HS.SNAP_ID = SS.SNAP_ID 
		AND HS.INSTANCE_NUMBER = SS.INSTANCE_NUMBER
WHERE HS.END_INTERVAL_TIME BETWEEN TO_DATE('&dt1', 'DD/MM/YYYY HH:MI:SS') AND TO_DATE('&dt2', 'DD/MM/YYYY HH:MI:SS')
 AND (HS.INSTANCE_NUMBER = &inst OR &inst = 0)
 AND SO.OBJECT_NAME = upper('&object_name')
 AND SO.OWNER = upper('&owner')
 GROUP BY HS.end_interval_time, hs.snap_id
 ORDER BY 1;

prompt 
prompt *************** TOTAL VALUES ***************************
prompt *************** ESTATISTICAS DE ESPACO *************** 
prompt   
SELECT hs.snap_id as "id", 
		to_char(HS.end_interval_time, 'DD/MM/YYYY HH24:MI') AS "Interval",		
		 (SUM(SPACE_USED_TOTAL) / 1024 / 1024) as "Space_Used_MB", 
		 (SUM(SPACE_ALLOCATED_TOTAL) / 1024 / 1024) as "Space_Alloc_MB", 
		 SUM(TABLE_SCANS_TOTAL) as "Table_Scans"
FROM DBA_HIST_SEG_STAT_OBJ SO
	 INNER JOIN DBA_HIST_SEG_STAT SS
		ON SO.DBID = SS.DBID
		 AND SO.TS# = SS.TS#
		 AND SO.OBJ# = SS.OBJ#
		 AND SO.DATAOBJ# = SS.DATAOBJ#
	 INNER JOIN DBA_HIST_SNAPSHOT HS
		ON HS.SNAP_ID = SS.SNAP_ID 
		AND HS.INSTANCE_NUMBER = SS.INSTANCE_NUMBER
WHERE HS.END_INTERVAL_TIME BETWEEN TO_DATE('&dt1', 'DD/MM/YYYY HH:MI:SS') AND TO_DATE('&dt2', 'DD/MM/YYYY HH:MI:SS')
 AND (HS.INSTANCE_NUMBER = &inst OR &inst = 0)
 AND SO.OBJECT_NAME = upper('&object_name')
 AND SO.OWNER = upper('&owner')
GROUP BY HS.end_interval_time, hs.snap_id
 ORDER BY 1;
prompt 
prompt 
prompt 
prompt *************** DELTA VALUES ***************************
prompt *************** ESTATISTICAS DE HARDWARE *************** 
prompt 
SELECT  hs.snap_id as "id", 
		to_char(HS.end_interval_time, 'DD/MM/YYYY HH24:MI') AS "Interval",
		SUM(LOGICAL_READS_DELTA) AS "LogicalReads", 
		SUM(BUFFER_BUSY_WAITS_DELTA) AS "BufferBusyWaits", 
		SUM(DB_BLOCK_CHANGES_DELTA) AS "BlockChanges",
		 SUM(PHYSICAL_READS_DELTA) AS "PhyReads", 
		 SUM(PHYSICAL_WRITES_DELTA) AS "PhyWrites", 
		 SUM(PHYSICAL_READS_DIRECT_DELTA) AS "DirectReads",  
		 SUM(PHYSICAL_WRITES_DIRECT_DELTA) AS "DirectWrites",  
		 SO.TABLESPACE_NAME AS "Tablespace"
FROM DBA_HIST_SEG_STAT_OBJ SO
	 INNER JOIN DBA_HIST_SEG_STAT SS
		ON SO.DBID = SS.DBID
		 AND SO.TS# = SS.TS#
		 AND SO.OBJ# = SS.OBJ#
		 AND SO.DATAOBJ# = SS.DATAOBJ#
	 INNER JOIN DBA_HIST_SNAPSHOT HS
		ON HS.SNAP_ID = SS.SNAP_ID 
		AND HS.INSTANCE_NUMBER = SS.INSTANCE_NUMBER
WHERE HS.END_INTERVAL_TIME BETWEEN TO_DATE('&dt1', 'DD/MM/YYYY HH:MI:SS') AND TO_DATE('&dt2', 'DD/MM/YYYY HH:MI:SS')
 AND (HS.INSTANCE_NUMBER = &inst OR &inst = 0)
 AND SO.OBJECT_NAME = upper('&object_name')
 AND SO.OWNER = upper('&owner')
 GROUP BY HS.end_interval_time, hs.snap_id, SO.TABLESPACE_NAME
 ORDER BY 1;
 

prompt 
prompt *************** DELTA VALUES ***************************
prompt *************** ESTATISTICAS DE GC + LOCKS *************** 
prompt  
SELECT hs.snap_id as "id", 
		to_char(HS.end_interval_time, 'DD/MM/YYYY HH24:MI') AS "Interval",
		SUM(ITL_WAITS_DELTA) AS "ITLWaits", 
		SUM(ROW_LOCK_WAITS_DELTA) as "RowLockWaits", 
		SUM(GC_CR_BLOCKS_SERVED_DELTA) AS "GC_CR_Blocks_Snd", 
		SUM(GC_CU_BLOCKS_SERVED_DELTA) AS "GC_CU_Blocks_Snd", 
		SUM(GC_BUFFER_BUSY_DELTA ) AS "GC_BufferBusy", 
		SUM(GC_CR_BLOCKS_RECEIVED_DELTA)  AS "GC_CR_Blocks_Rcv", 
		SUM(GC_CU_BLOCKS_RECEIVED_DELTA ) AS "GC_CU_Blocks_Rcv"
FROM DBA_HIST_SEG_STAT_OBJ SO
	 INNER JOIN DBA_HIST_SEG_STAT SS
		ON SO.DBID = SS.DBID
		 AND SO.TS# = SS.TS#
		 AND SO.OBJ# = SS.OBJ#
		 AND SO.DATAOBJ# = SS.DATAOBJ#
	 INNER JOIN DBA_HIST_SNAPSHOT HS
		ON HS.SNAP_ID = SS.SNAP_ID 
		AND HS.INSTANCE_NUMBER = SS.INSTANCE_NUMBER
WHERE HS.END_INTERVAL_TIME BETWEEN TO_DATE('&dt1', 'DD/MM/YYYY HH:MI:SS') AND TO_DATE('&dt2', 'DD/MM/YYYY HH:MI:SS')
 AND (HS.INSTANCE_NUMBER = &inst OR &inst = 0)
 AND SO.OBJECT_NAME = upper('&object_name')
 AND SO.OWNER = upper('&owner')
 GROUP BY HS.end_interval_time, hs.snap_id
 ORDER BY 1;

prompt 
prompt *************** DELTA VALUES ***************************
prompt *************** ESTATISTICAS DE ESPACO *************** 
prompt   
SELECT hs.snap_id as "id", 
		to_char(HS.end_interval_time, 'DD/MM/YYYY HH24:MI') AS "Interval",		
		 ROUND(SUM(SPACE_USED_DELTA) / 1024 / 1024) as "Space_Used_MB", 
		 ROUND(SUM(SPACE_ALLOCATED_DELTA) / 1024 / 1024) as "Space_Alloc_MB", 
		 SUM(TABLE_SCANS_DELTA) as "Table_Scans"
FROM DBA_HIST_SEG_STAT_OBJ SO
	 INNER JOIN DBA_HIST_SEG_STAT SS
		ON SO.DBID = SS.DBID
		 AND SO.TS# = SS.TS#
		 AND SO.OBJ# = SS.OBJ#
		 AND SO.DATAOBJ# = SS.DATAOBJ#
	 INNER JOIN DBA_HIST_SNAPSHOT HS
		ON HS.SNAP_ID = SS.SNAP_ID 
		AND HS.INSTANCE_NUMBER = SS.INSTANCE_NUMBER
WHERE HS.END_INTERVAL_TIME BETWEEN TO_DATE('&dt1', 'DD/MM/YYYY HH:MI:SS') AND TO_DATE('&dt2', 'DD/MM/YYYY HH:MI:SS')
 AND (HS.INSTANCE_NUMBER = &inst OR &inst = 0)
 AND SO.OBJECT_NAME = upper('&object_name')
 AND SO.OWNER = upper('&owner')
 GROUP BY HS.end_interval_time, hs.snap_id
 ORDER BY 1;

undef dt1  		
undef dt2  		
undef inst 		
undef object_name  
undef owner  		
