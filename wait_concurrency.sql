SELECT class, COUNT, time,
	ROUND(time * 100 / SUM(time) OVER (), 2) pct
FROM v$waitstat
ORDER BY time DESC;