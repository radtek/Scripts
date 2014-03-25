prompt se consistent gets waits(gc cr block 2-way + gc cr block 3-way) deve ser menor que 10% do tempo de "db file sequential read"
prompt 
SELECT event, 
	SUM(total_waits) total_waits,
	ROUND(SUM(time_waited_micro) / 1000000, 2) time_waited_secs,
	ROUND(SUM(time_waited_micro)/1000 / SUM(total_waits), 2) avg_ms
FROM gv$system_event
WHERE wait_class <> 'Idle'
 AND( event LIKE 'gc%block%way'
	OR event LIKE 'gc%multi%'
	or event like 'gc%grant%'
	OR event = 'db file sequential read')
GROUP BY event
HAVING SUM(total_waits) > 0
ORDER BY event;