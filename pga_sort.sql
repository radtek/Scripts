SELECT NAME, VALUE
FROM v$sysstat
WHERE NAME LIKE 'workarea executions - %'
OR NAME IN ('sorts (memory)', 'sorts (disk)');