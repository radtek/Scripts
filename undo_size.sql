break on tablespace_name skip 1

SELECT b.name as tablespace_name, round(SUM(a.bytes) / 1024 / 1024 / 1024) "UNDO_SIZE_GB"
FROM v$datafile a,
	 v$tablespace b,
	 dba_tablespaces c
 WHERE c.contents = 'UNDO'
 AND c.status = 'ONLINE'
 AND b.name = c.tablespace_name
 AND a.ts# = b.ts#
group by b.name;

select t.tablespace_name, 
	   round(d.allocated / 1024 / 1024, 0) allocatedMB, 
	   round(u.used  / 1024 / 1024, 0) usedMB, 
	   round(f.free / 1024 / 1024, 0) freeMB, 
	   round(round(f.free / 1024 / 1024, 0) / round(d.allocated / 1024 / 1024, 0) * 100, 0) "%free",
       t.status, 
	   d.cnt as cnt_arq, 
	   contents, 
	   t.extent_management extman, 
       t.segment_space_management segman,
	   round(d.maxsizeMb) maxsizeMbPossible
 from DBA_TABLESPACES T
     INNER JOIN (select sum(bytes) allocated, count(file_id) cnt, tablespace_name, 
			(sum(decode(autoextensible, 'YES', maxbytes, 'NO', bytes)) / 1024 / 1024) maxsizeMb
		 from dba_data_files 
		 group by tablespace_name) d
	ON t.tablespace_name = d.tablespace_name
     LEFT JOIN (select SUM(F.BYTES) FREE, F.tablespace_name 
		from DBA_FREE_SPACE F
		group by F.tablespace_name) f
	ON t.tablespace_name = f.tablespace_name
     LEFT JOIN (select sum(bytes) used, tablespace_name  
		from dba_segments 		
		group by tablespace_name) U
	ON t.tablespace_name = U.tablespace_name
where t.tablespace_name in (select c.tablespace_name from dba_tablespaces c where c.contents = 'UNDO')
ORDER BY t.tablespace_name;


SELECT tablespace_name, status, round(SUM(BYTES)/1024/1024) "MB" FROM DBA_UNDO_EXTENTS group by tablespace_name, status order by tablespace_name, status;