prompt medindo a latencia do LMS
prompt 
WITH sysstats AS (
SELECT instance_name,
	 SUM(CASE WHEN name LIKE 'gc cr%time' THEN VALUE END) cr_time,
	 SUM(CASE WHEN name LIKE 'gc current%time' THEN VALUE END) current_time,
	 SUM(CASE WHEN name LIKE 'gc current blocks served' THEN VALUE END) current_blocks_served,
	 SUM(CASE WHEN name LIKE 'gc cr blocks served' THEN VALUE END) cr_blocks_served
FROM gv$sysstat 
	JOIN gv$instance
		USING (inst_id)
WHERE name IN ('gc cr block build time', 'gc cr block flush time', 'gc cr block send time', 
'gc current block pin time', 'gc current block flush time', 'gc current block send time',
 'gc cr blocks served', 'gc current blocks served')
GROUP BY instance_name
)
SELECT instance_name , current_blocks_served, 
	ROUND(current_time*10/current_blocks_served,2) avg_current_ms, 
	cr_blocks_served, ROUND(cr_time*10/cr_blocks_served,2) avg_cr_ms
FROM sysstats;