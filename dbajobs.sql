prompt informe job=0 para todos

define job=&job
col INTERVAL format a50 wrapped
col LOG_USER format a10
col SCHEMA_USER format a10
col instance for 9999

SELECT JOB, LOG_USER, NEXT_DATE, FAILURES, BROKEN, last_date, LAST_SEC, INTERVAL, instance
FROM DBA_JOBS
where job = &job or &job = 0
order by job;

prompt 
prompt ********* FALHAS **********
select * from DBA_JOBS
where failures > 0
and last_date > sysdate - 1
order by failures desc;

undef job