
SELECT OWNER, object_name, VALUE row_lock_waits,
		ROUND(VALUE * 100 / SUM(VALUE) OVER (), 2) pct
FROM v$segment_statistics
WHERE statistic_name = 'row lock waits' 
AND VALUE > 0
AND rownum < 10
and owner not in ('SYS')
ORDER BY VALUE DESC;