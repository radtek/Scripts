prompt verificar a efetividade de cache plano com o result cache
prompt 
WITH result_cache AS 
(
 SELECT cache_id,
	COUNT( * ) cached_result_sets,
	 SUM(scan_count) hits
 FROM v$result_cache_objects
 GROUP BY cache_id
)
 SELECT /*+ ordered */
	 s.sql_id, 
	 s.executions, 
	 o.cached_result_sets,
	 o.hits cache_hits,
	 ROUND(s.rows_processed / executions) avg_rows,
	 buffer_gets,
	 ROUND(buffer_gets / (executions - o.hits))
	 avg_gets_nocache,
	 round((buffer_gets / (executions - o.hits))
	 *o.hits) estd_saved_gets,
	 s.sql_text
FROM v$sql_plan p
	 JOIN result_cache o
		ON (p.object_name = o.cache_id)
	 JOIN v$sql s
		 ON (s.sql_id = p.sql_id AND s.child_number = p.child_number)
WHERE operation = 'RESULT CACHE'
order by 7 desc ;