set lines 20000
col c1 heading 'SQL|ID'              format a13
col c2 heading 'Cost'                format 9999,999,999
col c3 heading 'SQL Text'            format a200 wrapped
set long 99999

select
  p.sql_id            c1,
  p.cost              c2,
  p.cpu_cost, 
  p.io_cost,
  p.temp_space,
  s.sql_text c3, 
  p.PLAN_HASH_VALUE
from
  dba_hist_sql_plan    p,
  dba_hist_sqltext     s
where
      p.id = 0
  and
      p.sql_id = s.sql_id
  and
      p.cost is not null
  and 
		p.object_owner not IN ('SYS', 'SYSTEM')
  and rownum < 10
order by  
  p.cost desc
;