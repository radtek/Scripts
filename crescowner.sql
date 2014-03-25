define dias=&dias
define owner=&owner

col MB format 9999999999
break on report
compute avg of MB on report skip 1

select to_date(to_char(timestamp, 'DD/MM/YYYY'), 'DD/MM/YYYY') as data, 
       round(sum(total_bytes)  / 1024 / 1024) as MB 
from system.imm_storage 
where segment_owner = upper('&&owner')
and timestamp > sysdate -&&dias
group by segment_owner, to_date(to_char(timestamp, 'DD/MM/YYYY'), 'DD/MM/YYYY')
order by to_date(to_char(timestamp, 'DD/MM/YYYY'), 'DD/MM/YYYY');

clear breaks
undef owner
undef dias