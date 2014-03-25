
prompt *********************************************
prompt Obs: Executar begin backup -> copy -> depois rodar todo bloco final em conjunto para evitar downtime do datafile(ctrl+c -> ctrl +v)
prompt Informar caminho completo no datafile e novo datafile
prompt *********************************************


set verify off
col id noprint
def datafile=&datafile
def datafile_nova_loc=&datafile_nova_loc

select '>>>>>>>>>>>>>>>>>>>ERRO! DATAFILE JÀ EXISTENTE NO DESTINO<<<<<<<<<<<<<<<<<<<<<<<<<<<'
from dba_data_files d
where d.file_name = '&&datafile_nova_loc';

select 1 id, 'alter tablespace '||d.tablespace_name||' begin backup;'
from dba_data_files d
where d.file_name = '&&datafile'
union all
select 2 id, '   ' from dual
union all
select 3 id, 'cp &&datafile &&datafile_nova_loc' from dual
union all
select 4 id, '   ' from dual
union all
select 5 id, 'alter tablespace '||d.tablespace_name||' end backup;'
from dba_data_files d
where d.file_name = '&&datafile'
union all
select 6 id, 'alter database datafile ''&&datafile'' offline;' from dual
union all
select 7 id, 'alter database rename file ''&&datafile'' to ''&&datafile_nova_loc'';' from dual
union all
select 8 id, 'recover datafile ''&&datafile_nova_loc'';' from dual
union all
select 9 id, 'alter database datafile ''&&datafile_nova_loc'' online;' from dual
order by id;

prompt *********************************************
prompt verificar se deve remover arquivo antigo:
select 'rm -f &&datafile' from dual;
prompt validar status dos datafiles no final
prompt select * from v$backup where status = 'ACTIVE';
prompt *********************************************

undef datafile
undef datafile_nova_loc
col id print
set verify on
