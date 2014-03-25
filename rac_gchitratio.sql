WITH sysstats AS 
(
 SELECT inst_id,
	SUM(CASE WHEN name LIKE 'gc%received' THEN VALUE END) gc_blocks_received,
	SUM(CASE WHEN name = 'session logical reads' THEN VALUE END) logical_reads,
	SUM(CASE WHEN name = 'physical reads' THEN VALUE END) physical_reads
 FROM gv$sysstat
 GROUP BY inst_id
)
SELECT instance_name, 
	logical_reads, 
	gc_blocks_received, 
	physical_reads,
	ROUND(physical_reads*100/logical_reads,2) phys_to_logical_pct,
	ROUND(gc_blocks_received*100/logical_reads,2) gc_to_logical_pct
FROM sysstats 
	JOIN  gv$instance
	USING (inst_id);