Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
Accept instance prompt 'Instance:'

select snap_id, snap_time, instance_number, snap_level
from stats$snapshot
where (instance_number = &instance or &instance = 0)
and snap_time between to_date('&dt1', 'DD/MM/YYYY HH24:MI:SS') and to_date('&dt2', 'DD/MM/YYYY HH24:MI:SS')
order by instance_number, snap_time;

undef dt1
undef dt2
undef instance