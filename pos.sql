set pages 10000
col name for a50
col delta for 9999999999999999999

select s.name, ( m2.value - m.value ) delta 
from my_stats m, v$mystat m2, V$STATNAME s 
where m.STATISTIC#   = m2.STATISTIC# 
and m.STATISTIC#    = s.STATISTIC# 
and m.value != m2.value 
order  by 2 desc;