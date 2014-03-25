prompt hit ratio mais preciso, pois considera directio IO e non direct IO
prompt desde startup, ideal coletar valores e recalcular a cada x tempo
SELECT name, block_size / 1024 block_size_kb, current_ size, target_size,prev_size
FROM v$buffer_pool;

WITH sysstats AS
(
SELECT CASE WHEN name LIKE '%direct' THEN 'Direct'
		WHEN name LIKE '%cache' THEN 'Cache'
		ELSE 'All' END AS category,
		CASE WHEN name LIKE 'consistent%' THEN 'Consistent'
			 WHEN name LIKE 'db block%' THEN 'db block'
			ELSE 'physical' END AS TYPE, 
		VALUE
 FROM v$sysstat
 WHERE name IN ('consistent gets',
		'consistent gets direct',
		'consistent gets from cache',
		'db block gets',
		'db block gets direct',
		'db block gets from cache',
		'physical reads', 
		'physical reads cache',
		'physical reads direct')
)	
 SELECT category, 
	db_block, 
	consistent, 
	physical,
	ROUND(DECODE(category,'Direct', NULL,((db_block + consistent) - physical)* 100/ (db_block + consistent)), 2) AS hit_rate
 FROM (  SELECT category, 
			SUM(DECODE(TYPE, 'db block', VALUE)) db_block,
			SUM(DECODE(TYPE, 'Consistent', VALUE)) consistent,
			SUM(DECODE(TYPE, 'physical', VALUE)) physical
		 FROM sysstats
		 GROUP BY category)
 ORDER BY category DESC;