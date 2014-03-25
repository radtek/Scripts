accept object_name prompt 'Enter Table Name:'

col c0 heading 'Begin|Interval|time' format a8
col c1 heading 'Owner'               format a10
col c2 heading 'Object|Type'         format a10
col c3 heading 'Object|Name'         format a15
col c4 heading 'Average|CPU|Cost'    format 999,999,999,999
col c5 heading 'Average|IO|Cost'     format 999,999,999,999


break on c1 skip 2
break on c2 skip 2

select
  to_char(sn.begin_interval_time,'mm-dd hh24') c0,  
  p.object_owner                               c1,
  p.object_type                                c2,
  p.object_name                                c3,
  avg(p.cpu_cost)                              c4,
  avg(p.io_cost)                               c5
from
  dba_hist_sql_plan p,
  dba_hist_sqlstat  st,
  dba_hist_snapshot sn
where
  p.object_name is not null
and 
   p.object_owner <> 'SYS'
and
   p.object_name = &object_name
and
  p.sql_id = st.sql_id
and
  st.snap_id = sn.snap_id     
group by
  to_char(sn.begin_interval_time,'mm-dd hh24'),
  p.object_owner,
  p.object_type,
  p.object_name
order by
  1,2,3 desc
;

undef object_name