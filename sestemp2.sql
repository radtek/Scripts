col sid format 999999
col username format a10
col event format a25
col TBS format a10
col machine format a20
col segtype format a8
col extents format 9999

select s.sid, username, logon_time, status, event, TBS, segtype, extents,MB_usando, machine, blocking_session, sql_id
from v$session s
inner join (select sid, TBS, segtype, extents,MB_usando
from (
SELECT /*+ Ordered use_nl(u,s,t) */
       s.sid, s.username, u.tablespace TBS, u.segtype, u.extents,
       (u.blocks * (select value from v$parameter where name = 'db_block_size')) /1024/1024 MB_usando,
       (select sum(f.bytes) from dba_temp_files f where f.tablespace_name = u.tablespace) /1024/1024 Total_temp_mb,
      i.instance_name, i.host_name
FROM v$sort_usage u, v$session s, v$instance i
WHERE s.saddr      = u.session_addr
order by MB_usando desc) tbl) tbl
   on tbl.sid = s.sid;
