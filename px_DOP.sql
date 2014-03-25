SELECT name,value, round(value*100/sum(value) over(),2) pct
FROM v$sysstat
WHERE name LIKE 'Parallel operations%downgraded%';