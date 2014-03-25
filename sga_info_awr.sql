select 	to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS interval, 		
		NVL(ss.POOL, 'buffer cache') pool,
		SUM(ROUND(SS.BYTES / 1024/ 1024 )) AS MB, 
		hs.snap_id
from DBA_HIST_SGASTAT SS
	INNER JOIN DBA_HIST_SNAPSHOT HS
		ON SS.SNAP_ID = HS.SNAP_ID
		AND SS.INSTANCE_NUMBER = HS.INSTANCE_NUMBER
where hs.INSTANCE_NUMBER = &instance
 AND  hs.end_interval_time between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
group by  hs.snap_id, 
		to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI'), 
		NVL(ss.POOL, 'buffer cache')
ORDER BY NVL(ss.POOL, 'buffer cache'), hs.snap_id;