
column sql_text format a128 wrapped
col sid format 9999999
SELECT a.username, a.sid, a.serial#, a.osuser, b.segtype,
	sum(b.blocks * (select value from v$parameter where name = 'db_block_size')) as size_KB, 
	c.sql_id, c.hash_value, c.sql_text, b.tablespace, i.instance_name, i.host_name
  FROM gv$session a, gv$sort_usage b, gv$sqlarea c, gv$instance i
  WHERE a.saddr = b.session_addr
  AND c.address= a.sql_address
  AND c.hash_value = a.sql_hash_value
  and i.INST_ID = a.INST_ID
group by a.username, a.sid, a.serial#, a.osuser, b.segtype,
	c.sql_id, c.hash_value, c.sql_text, b.tablespace, i.instance_name, i.host_name
ORDER BY b.tablespace, size_KB;
  
SELECT /*+ Ordered use_nl(u,s,t) */
       s.sid, s.username, u.tablespace TBS, u.segtype, u.extents,
       (u.blocks * (select value from v$parameter where name = 'db_block_size')) /1024/1024 MB_usando,
       (select sum(f.bytes) from dba_temp_files f where f.tablespace_name = u.tablespace) /1024/1024 Total_temp_mb, 
	   i.instance_name, i.host_name, s.sql_id
FROM gv$sort_usage u, gv$session s, gv$instance i
WHERE s.saddr      = u.session_addr
  and i.INST_ID = s.INST_ID
order by S.sid;
