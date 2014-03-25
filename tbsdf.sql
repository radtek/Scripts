col file_name for a60
select b.Tablespace_name TABLESPACE, b.status , a.file_name,  (a.bytes/1024/1024) ATUAL_MB , c.status STATUS, (a.maxbytes/1024/1024) LIMITE_GB
from dba_data_files a, dba_tablespaces b, v$datafile c
where a.tablespace_name like upper('&TABLESPACE')
and  a.tablespace_name = b.tablespace_name
and a.file_id = c.FILE#
order by 1;