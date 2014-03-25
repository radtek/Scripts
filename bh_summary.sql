prompt podemos ter dirty blocos e before image, percentual pode ser maior que 100%
prompt v$BH.STATUS demostra se colunas é current block(xcur) ou mantida para consistent read(cr)
prompt
SELECT s.buffer_pool, o.owner || '.' || o.object_name segment,
	COUNT( * ) cached_blocks, s.blocks seg_blocks,
	ROUND(COUNT( * ) * 100 / s.blocks, 2) pct_cached,
	SUM(DECODE(dirty, 'Y', 1, 0)) dirty_blocks
FROM v$bh
	JOIN dba_objects o ON (object_id = objd)
	JOIN dba_segments s ON (o.owner = s.owner AND object_name = segment_name)
GROUP BY s.buffer_pool, s.blocks, o.owner, o.object_name
HAVING COUNT( * ) > 100
ORDER BY COUNT( * ) DESC;