

column file_name format a55
def tablespace = &ts

select file_name, 
	round(df.bytes / 1024 / 1024,0) sizeMB, 
	vdf.status, 
	df.AUTOEXTENSIBLE, 
	round(df.MAXBYTES / 1024 / 1024,0) maxmb, 
	round(f.free / 1024 / 1024,0) as freeMB,
	 (df.INCREMENT_BY * (select block_size from dba_tablespaces where tablespace_name=upper('&tablespace'))) / 1024 / 1024 as INCREMENT_BY_MB
from v$datafile vdf
	inner join dba_data_FILES df
		on vdf.file# = df.file_id
		and vdf.name = df.file_name
	left join 
		(select SUM(BYTES) FREE, tablespace_name, file_id
		 from DBA_FREE_SPACE 
		 group by tablespace_name, file_id) f
		on df.file_id = f.file_id
		and df.tablespace_name = f.tablespace_name
where df.tablespace_name = upper('&tablespace')
order by 1;


undef tablespace