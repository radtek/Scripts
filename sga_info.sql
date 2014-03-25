prompt algumas informações da SGA
prompt demonstra o ganulo size
prompt free memory 
select name, round((bytes / 1024 / 1024)) as mb from v$sgainfo order by 2 desc;