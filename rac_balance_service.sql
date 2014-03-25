prompt demonstra o balanceamento no cluster e instance por services
prompt 

BREAK ON instance_name skip 1
COMPUTE SUM OF cpu_time ON instance_name

WITH service_cpu AS 
(
 SELECT instance_name, 
	service_name,
	round(SUM(VALUE)/1000000,2) cpu_time
 FROM     gv$service_stats
	JOIN gv$instance
		USING (inst_id)
 WHERE stat_name IN ('DB CPU', 'background cpu time')
 GROUP BY  instance_name, service_name 
)
SELECT instance_name, 
	service_name, 
	cpu_time,
	ROUND(cpu_time * 100 / SUM(cpu_time) OVER (PARTITION BY instance_name), 2) pct_instance,
	ROUND(  cpu_time * 100 / SUM(cpu_time) OVER (PARTITION BY service_name), 2) pct_service
FROM service_cpu
WHERE cpu_time > 0
ORDER BY instance_name, 
	service_name;