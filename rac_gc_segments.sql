prompt listar os segmentos que mais sofrem com gc requests
prompt podemos ter um mal design da aplicação
prompt 
WITH segment_misses AS
(
 SELECT owner || '.' || object_name segment_name,
	SUM(VALUE) gc_blocks_received,
	ROUND(  SUM(VALUE)* 100 / SUM(SUM(VALUE)) OVER (), 2) pct
 FROM gv$segment_statistics
 WHERE statistic_name LIKE 'gc%received' AND VALUE > 0
 GROUP BY owner || '.' || object_name)
SELECT segment_name,gc_blocks_received,pct
FROM segment_misses
WHERE pct > 1
ORDER BY pct DESC;
	SEGMENT_NAME             