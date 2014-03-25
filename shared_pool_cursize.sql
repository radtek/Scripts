prompt
prompt demostrar current shared pool size
prompt
column bytes format 999999999999999
select bytes,bytes/1024/1024/1024 size_gb 
from v$sgainfo 
where name='Shared Pool Size';
