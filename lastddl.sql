select * from (
select owner, object_name, object_type, created, last_ddl_time, status from dba_objects where object_type <> 'DATABASE LINK' order by last_ddl_time desc)
where rownum <= 50
order by last_ddl_time
/