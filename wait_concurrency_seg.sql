SELECT owner, object_name, SUM(VALUE) buffer_busy_count ,
	round(sum(value) * 100/sum(sum(value)) over(),2) pct
FROM v$segment_statistics
WHERE statistic_name IN ('gc buffer busy', 'buffer busy waits')
	AND VALUE > 0
GROUP BY owner, object_name
ORDER BY SUM(VALUE) DESC;
