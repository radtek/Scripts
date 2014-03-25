     select w.p1,w.p1text,
         w.p2text,w.p2,w.p3text,w.p3, w.p3text,
	(select partition_name from dba_extents where 
	 file_id = w.p1
	 and w.p2 between block_id and block_id + blocks) part
  from v$session_wait w
 where sid=2181
/
