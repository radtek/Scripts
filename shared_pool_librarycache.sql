	SELECT namespace, gets, gethits,
	ROUND(CASE gets WHEN 0 
		THEN NULL
		ELSE gethits * 100 / gets END, 2) hitratio,
	 ROUND(gets * 100 / SUM(gets) OVER (), 2) pct_gets,
	 ROUND((gets - gethits) * 100 /	 SUM(gets - gethits) OVER (), 2) pct_misses
FROM v$librarycache;