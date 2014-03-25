prompt ver objetos no buffer cache com mais blocos
prompt 
select B.* from (
  SELECT OWNER, OBJECT_TYPE,
    (case when (OBJECT_TYPE = 'LOB') then
      (select table_name || ' . ' || column_name from dba_lobs
        where segment_name = A.OBJECT_NAME and OWNER = A.OWNER)
     else
      (case when (OBJECT_TYPE = 'LOB PARTITION') then
        (select table_name || ' . ' || column_name from dba_lob_partitions
          where lob_name = A.OBJECT_NAME and OWNER = A.OWNER
            and lob_partition_name = A.subobject_name)
       else
        OBJECT_NAME
       end)
     end) as OBJECT_NAME
    ,(case when (OBJECT_TYPE = 'LOB PARTITION') then
      (select partition_name from dba_lob_partitions
        where lob_name = A.OBJECT_NAME and OWNER = A.OWNER
          and lob_partition_name = A.subobject_name)
     else
      subobject_name
    end)
     as partition_name
    ,MB
    ,round((mb/(sum(mb) over ()))*100) as pct_mb
    ,(select round(bytes/1024/1024) from dba_segments where segment_name = A.OBJECT_NAME
      and segment_type like A.OBJECT_TYPE || '%' and OWNER = A.OWNER
      and (partition_name is null or partition_name = A.subobject_name)) as seg_mb
    ,BLKS
    ,round((BLKS/(sum(BLKS) over ()))*100) as pct_blks
    ,(select blocks from dba_segments where segment_name = A.OBJECT_NAME
      and segment_type like A.OBJECT_TYPE || '%' and OWNER = A.OWNER
      and (partition_name is null or partition_name = A.subobject_name)) as seg_blks
    ,(select buffer_pool from dba_segments where segment_name = A.OBJECT_NAME
      and segment_type like A.OBJECT_TYPE || '%' and OWNER = A.OWNER
      and (partition_name is null or partition_name = A.subobject_name)) as seg_pool
    ,(select tablespace_name from dba_segments where segment_name = A.OBJECT_NAME
      and segment_type like A.OBJECT_TYPE || '%' and OWNER = A.OWNER
      and (partition_name is null or partition_name = A.subobject_name)) as seg_tbs
    ,sum(MB) over () as sum_mb
    ,sum(BLKS) over () as sum_BLKS
  from (
    SELECT o.OBJECT_NAME, o.OBJECT_TYPE, o.OWNER, o.subobject_name, COUNT(*) BLKS,
      round(COUNT(*)*8/1024) as MB
    FROM DBA_OBJECTS o, V$BH bh
      WHERE o.DATA_OBJECT_ID = bh.OBJD        
    GROUP BY o.OBJECT_NAME, o.OWNER, o.OBJECT_TYPE, o.subobject_name
    order by count(*) desc
  ) A
  ORDER BY blks desc
) B
where rownum =< 20
/