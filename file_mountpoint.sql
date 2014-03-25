define filepath=upper('&filepath')
select tablespace_name, file_name
from dba_data_files
where file_name like &filepath
union all
select tablespace_name, file_name
from dba_temp_files
where file_name like &filepath
union all
select 'REDO', member
from v$logfile
where member like &filepath
union all
select 'CONTROL', name
from v$controlfile
where name like &filepath
undefine filepath