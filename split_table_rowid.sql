select
 'rowid between '''||sys.dbms_rowid.rowid_create(1, d.oid, c.fid1, c.bid1, 0)||''' and '''||
 sys.dbms_rowid.rowid_create(1, d.oid, c.fid2, c.bid2, 9999)||''''
from
 (select
 distinct b.rn,
 first_value(a.fid) over (partition by b.rn order by a.fid, a.bid rows between unbounded preceding and unbounded following) fid1,
 last_value(a.fid) over (partition by b.rn order by a.fid, a.bid rows between unbounded preceding and unbounded following) fid2,
 first_value(decode(sign(range2-range1), 1, a.bid+((b.rn-a.range1)*a.chunks1), a.bid)) over
 (partition by b.rn order by a.fid, a.bid rows between unbounded preceding and unbounded following) bid1,
 last_value(decode(sign(range2-range1), 1, a.bid+((b.rn-a.range1+1)*a.chunks1)-1, (a.bid+a.blocks-1))) over
 (partition by b.rn order by a.fid, a.bid rows between unbounded preceding and unbounded following) bid2
 from
 (select
 fid,
 bid,
 blocks,
 chunks1,
 trunc((sum2-blocks+1-0.1)/chunks1) range1,
 trunc((sum2-0.1)/chunks1) range2
 from
 (select /*+ rule */
 relative_fno fid,
 block_id bid,
 blocks,
 sum(blocks) over () sum1,
 trunc((sum(blocks) over ())/&&rowid_ranges) chunks1,
 sum(blocks) over (order by relative_fno, block_id) sum2
 from dba_extents
 where
 segment_name = upper('&&segment_name') and
 owner = upper('&&owner')
 )
 where
 sum1 > &&rowid_ranges
 ) a,
 (select rownum-1 rn from dual connect by level <= &&rowid_ranges) b
 where
 b.rn between a.range1 and a.range2
 ) c,
 (select max(data_object_id) oid from dba_objects
 where object_name = upper('&&segment_name') and owner = upper('&&owner') and data_object_id is not null
 ) d
/


undef segment_name
undef owner
undef rowid_ranges