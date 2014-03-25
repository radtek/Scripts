define instance_number=&instance_number
col namespace for a25
col end_interval_time for a15

break on report
break on namespace skip 2

select       
   LC.namespace,
   to_char(SP.end_interval_time, 'DD/MM/RR HH24:MI:SS') interval,
   LC.pins,
   LC.pins-LC.pinhits as loads,
   LC.reloads,
   LC.invalidations,
   round(100*(LC.reloads-LC.invalidations) / (LC.pins-LC.pinhits), 2) "%reloads"
from DBA_HIST_LIBRARYCACHE LC
	INNER JOIN DBA_HIST_SNAPSHOT SP
		ON LC.SNAP_ID = SP.SNAP_ID
		AND LC.DBID = SP.DBID
		AND LC.INSTANCE_NUMBER = SP.INSTANCE_NUMBER
where SP.INSTANCE_NUMBER = &instance_number
and SP.end_interval_time between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
and LC.pins>0
ORDER BY LC.namespace, SP.end_interval_time;

undefine instance_number