prompt demostra como está o ratio da data dictionary cache
SELECT PARAMETER
, SUM(GETS) as gets
, SUM(GETMISSES) as getmisses
, 100 * SUM(GETS-GETMISSES) / SUM(GETS) PCT_SUCC_GETS
, SUM(MODIFICATIONS) UPDATES
, sum("COUNT") as num
, sum(usage) as usage
FROM V$ROWCACHE
WHERE GETS > 0
GROUP BY PARAMETER;

prompt baixo ratio pode indicar problema de sizing
SELECT (SUM(GETS - GETMISSES - FIXED)) / SUM(GETS) "ROW CACHE" FROM V$ROWCACHE;





