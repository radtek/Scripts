

prompt informe o nome da tablespace ou % para todas

select t.tablespace_name name, 
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
where upper(t.tablespace_name) like upper('&tablespace_name')
ORDER BY t.tablespace_name;
