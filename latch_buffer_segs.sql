prompt identificar pelos chains, quais são os hot segments para identificar cache buffer chains
prompt precisa executar como sys
WITH cbc_latches AS
(
	SELECT 
		addr, 
		name, 
		sleeps, 
		rank() over(order by sleeps desc) ranking
	FROM v$latch_children
	WHERE name = 'cache buffers chains'
)
SELECT owner, 
		object_name,
		object_type,
		COUNT(distinct l.addr) latches,
		SUM(tch) touches
FROM cbc_latches l 
	JOIN x$bh b 
		ON (l.addr = b.hladdr)
	JOIN dba_objects o 
		ON (b.obj = o.object_id)
WHERE l.ranking <=100
GROUP BY owner, object_name,object_type
ORDER BY sum(tch) DESC;