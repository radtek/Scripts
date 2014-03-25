prompt informe um tipo ou % para todos
prompt tipos: CONTROLFILE,DATAFILE,ONLINELOG,TEMPFILE...
prompt 
define type=&type
define maxreg=&maxreg

col type format a20
col group_name format a30
col file_name format a50
col bytes_mb format 9999999
col space_alloc_mb format 9999999
col block_size format 9999999
col blocks format 9999999
col redundancy format a15
col striped format a15
col tot_reads format 9999999
col tot_writes format 9999999
col tot_mb_read format 9999999
col tot_mb_wrtn format 9999999

SELECT *
FROM (
		SELECT
			 AF.type
			,ADG.name group_name
			,AF.file_number
			,AA.name file_name			
			,round((AF.bytes / (1024*1024))) bytes_mb
			,round((AF.space / (1024*1024))) space_alloc_mb
			,AF.block_size
			,AF.blocks
			,AF.redundancy
			,AF.striped
			,(AF.cold_reads + AF.hot_reads) tot_reads
			,(AF.cold_writes + AF.hot_writes) tot_writes
			,round(((AF.cold_bytes_read + AF.hot_bytes_read) / (1024*1024))) tot_mb_read
			,round(((AF.cold_bytes_written + AF.hot_bytes_written) / (1024*1024))) tot_mb_wrtn
		  FROM 
			v$asm_file AF
		   ,v$asm_alias AA
		   ,v$asm_diskgroup ADG
		 WHERE AF.file_number = AA.file_number
		   AND AF.group_number = ADG.group_number
		   AND AA.group_number = ADG.group_number
   		   AND AF.type LIKE UPPER('%&type%')
		 ORDER BY bytes_mb desc) TBL
where rownum <= &maxreg;

undef type
undef maxreg