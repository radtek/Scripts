prompt informar mount point ex: %d01%
column FILE_NAME format a60
select *
from 
	(select df.file_name, round(df.bytes / 1024 / 1024, 0) AS SIZE_MB, df.status, df.AUTOEXTENSIBLE, df.MAXBYTES / 1024 / 1024 maxmb
	from dba_data_FILES df
		 inner join v$datafile vdf
			on vdf.name = df.file_name
	where df.file_name like '&mountpoint'
	and vdf.status <> 'OFFLINE'
	order by SIZE_MB DESC) tbl
where rownum <= 100
order by SIZE_MB DESC;

