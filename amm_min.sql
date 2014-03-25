SELECT name, 
	display_value, 
	description
FROM v$parameter
WHERE name IN
	('sga_target',
	'memory_target',
	'memory_max_target',
	'pga_aggregate_target',
	'shared_pool_size',
	'large_pool_size',
	'java_pool_size')
OR name LIKE 'db%cache_size'
ORDER BY name;
