prompt *** informe "%" para todos os valores
prompt *** Obs: lista somente os top 10
col size_MB format 999,999,999,999

select *
from (select df.file_name, round(df.bytes / 1024 / 1024) as size_MB
	  from dba_data_files df 
			inner join dba_tablespaces ts
				on ts.tablespace_name = df.tablespace_name		 
	  where upper(df.file_name) like upper('&filename') 
		and upper(df.tablespace_name) like upper('&tablespace_name')
		and ts.contents <> 'UNDO'
	  order by 2 desc) tbl
where rownum < 10
order by 2 desc;