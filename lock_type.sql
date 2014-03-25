column type format a4
column name format a25
column description format a50

SELECT TYPE, name, description
  FROM v$lock_type
 ORDER BY TYPE; 