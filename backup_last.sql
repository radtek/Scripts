col BACKUP_TYPE format a15 heading 'BACKUP|TYPE'
col CONTROLFILE_INCLUDED format a5 heading "CONTROLFILE"
col INCREMENTAL_LEVEL format 99999 heading "INC_LEVEL"
col MULTI_SECTION format a5 heading "MULTI|SECTION"

SELECT 	  
	   bkpdet.SET_STAMP,
	   TBL.COMPLETION_TIME, 
	   bkpdet.START_TIME, 
	   DECODE(TBL.BACKUP_TYPE, 'L', 'ARCH', 
							   'D', 'FULL', 
							   'I', 'INC') AS TYPE, 
	   TBL.INCREMENTAL_LEVEL, 
	   TO_CHAR (TRUNC (SYSDATE) + NUMTODSINTERVAL (bkpdet.ELAPSED_SECONDS, 'second'),'hh24:mi:ss') ELAPSED, 
	   ROUND(bkpdet.OUTPUT_BYTES / 1024/1024/1024) OUTPUT_GB
FROM(select max(COMPLETION_TIME) as COMPLETION_TIME, 
		    BACKUP_TYPE,
		    INCREMENTAL_LEVEL	 
	 from v$backup_set
	 group by BACKUP_TYPE, INCREMENTAL_LEVEL) TBL
	 LEFT JOIN v$backup_set_details bkpdet
		ON bkpdet.COMPLETION_TIME = TBL.COMPLETION_TIME
		AND bkpdet.BACKUP_TYPE = TBL.BACKUP_TYPE
		AND bkpdet.INCREMENTAL_LEVEL = TBL.INCREMENTAL_LEVEL	 
ORDER BY bkpdet.COMPLETION_TIME;