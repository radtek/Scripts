COL group_number        FORMAT 999          HEADING 'GroupNumber' 
COL group_name          FORMAT A12          HEADING 'DiskGroup'
COL file_number         FORMAT 9999         HEADING 'FileNumber'
COL file_name           FORMAT A30          HEADING 'FileName' WRAP
COL block_size          FORMAT 99999        HEADING 'Block|Size'
COL blocks              FORMAT 99999999     HEADING 'Blocks'
COL bytes_mb            FORMAT 99999        HEADING 'Size|(MB)'
COL space_alloc_mb      FORMAT 999999       HEADING 'Space|Alloc|(MB)'
COL type                FORMAT A18          HEADING 'File Type' WRAP
COL redundancy          FORMAT A06          HEADING 'Redun-|dancy'
COL striped             FORMAT A07          HEADING 'Striped'
COL tot_reads           FORMAT 9999999999      HEADING 'Total|Reads'
COL tot_writes          FORMAT 9999999999      HEADING 'Total|Writes'
COL tot_mb_read         FORMAT 9999999999      HEADING 'Total|Read|(MB)'
COL tot_mb_wrtn         FORMAT 9999999999      HEADING 'Total|Wrtn|(MB)'
SELECT *
FROM (
		SELECT
			 AF.type
			,ADG.name group_name
			,AF.file_number
			,AA.name file_name			
		--  ,TO_CHAR(AF.creation_date, 'mm-dd-yyyy hh24:mi:ss') created_on
			,(AF.cold_reads + AF.hot_reads) tot_reads
			,(AF.cold_writes + AF.hot_writes) tot_writes
			,((AF.cold_bytes_read + AF.hot_bytes_read) / (1024*1024)) tot_mb_read
			,((AF.cold_bytes_written + AF.hot_bytes_written) / (1024*1024)) tot_mb_wrtn
			,AF.block_size
			,AF.blocks
			,(AF.bytes / (1024*1024)) bytes_mb
			,(AF.space / (1024*1024)) space_alloc_mb
			,AF.redundancy
			,AF.striped
		  FROM 
			v$asm_file AF
		   ,v$asm_alias AA
		   ,v$asm_diskgroup ADG
		 WHERE AF.file_number = AA.file_number
		   AND AF.group_number = ADG.group_number
		   AND AA.group_number = ADG.group_number
		   AND AF.type IN ('CONTROLFILE','DATAFILE','ONLINELOG','TEMPFILE')
		 ORDER BY tot_reads desc) TBL
where rownum < 10;

SELECT *
FROM (
		SELECT
			 AF.type
			,ADG.name group_name
			,AF.file_number
			,AA.name file_name			
		--  ,TO_CHAR(AF.creation_date, 'mm-dd-yyyy hh24:mi:ss') created_on
			,(AF.cold_reads + AF.hot_reads) tot_reads
			,(AF.cold_writes + AF.hot_writes) tot_writes
			,((AF.cold_bytes_read + AF.hot_bytes_read) / (1024*1024)) tot_mb_read
			,((AF.cold_bytes_written + AF.hot_bytes_written) / (1024*1024)) tot_mb_wrtn
			,AF.block_size
			,AF.blocks
			,(AF.bytes / (1024*1024)) bytes_mb
			,(AF.space / (1024*1024)) space_alloc_mb
			,AF.redundancy
			,AF.striped
		  FROM 
			v$asm_file AF
		   ,v$asm_alias AA
		   ,v$asm_diskgroup ADG
		 WHERE AF.file_number = AA.file_number
		   AND AF.group_number = ADG.group_number
		   AND AA.group_number = ADG.group_number
		   AND AF.type IN ('CONTROLFILE','DATAFILE','ONLINELOG','TEMPFILE')
		 ORDER BY tot_writes desc) TBL
where rownum < 10;