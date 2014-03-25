
break on TABLESPACE_NAME
compute sum of SIZEMB on TABLESPACE_NAME skip 1

column file_name format a50

select DECODE(df.tablespace_name, (SELECT PROPERTY_VALUE from DATABASE_PROPERTIES where property_name = 'DEFAULT_TEMP_TABLESPACE'), 'TRUE', 'FALSE') AS DEFAULT_TBS,
	df.tablespace_name,
    df.file_name, 
	round(bytes / 1024 / 1024,0) sizeMB, 
	status, 
	AUTOEXTENSIBLE, 
	round(MAXBYTES / 1024 / 1024,0) maxmb, 
	round(f.BYTES_FREE / 1024 / 1024,0) as freeMB,
	round(f.BYTES_USED / 1024 / 1024,0) as UsedMB,
	 (INCREMENT_BY * (select block_size from dba_tablespaces where tablespace_name=(SELECT PROPERTY_VALUE from DATABASE_PROPERTIES where property_name = 'DEFAULT_TEMP_TABLESPACE'))) / 1024 / 1024 as INCREMENT_BY_MB
from dba_temp_FILES df
	left join 
		(SELECT TABLESPACE_NAME, FILE_ID, BYTES_USED, BYTES_FREE FROM V$TEMP_SPACE_HEADER) f
		on df.file_id = f.file_id
		and df.tablespace_name = f.tablespace_name
order by tablespace_name;
