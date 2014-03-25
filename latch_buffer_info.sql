prompt identificar médias de blocos por cache buffer chains

SELECT COUNT(DISTINCT l.addr) cbc_latches, SUM(COUNT( * )) buffers, MIN(COUNT( * )) min_buffer_per_latch,
	MAX(COUNT( * )) max_buffer_per_latch, ROUND(AVG(COUNT( * ))) avg_buffer_per_latch
FROM v$latch_children l
		JOIN x$bh b ON (l.addr = b.hladdr)
WHERE name = 'cache buffers chains'
GROUP BY l.addr;