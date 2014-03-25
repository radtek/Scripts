prompt informe job = 0 para todos ou informe o id do job
prompt informe what ou % para todos
define job = &job
define what = &what

col instance format 9999
col SCHEMA_USER format a30
col LOG_USER format a20
col what format a128 wrapped
select job, SCHEMA_USER, LOG_USER, what, instance from dba_jobs where (job = &job or &job = 0)
and upper(what) like upper('&what');

undef job
undef what