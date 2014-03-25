prompt informar mount point ex: %d01%
column FILE_NAME format a60
select *
from 
	(select file_name, round(bytes / 1024 / 1024, 0) AS SIZE_MB, status, AUTOEXTENSIBLE, MAXBYTES / 1024 / 1024 maxmb
	from dba_data_FILES 
	where file_name like '&mountpoint'
	order by SIZE_MB DESC) tbl
where rownum <= 100
order by SIZE_MB DESC;

