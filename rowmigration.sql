SELECT a.name, b.value
  FROM v$statname a, v$mystat b
 WHERE a.statistic# = b.statistic#
   AND lower(a.name) = 'table fetch continued row';