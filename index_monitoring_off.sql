define OWNER='&OWNER'
define TABLE_NAME='&TABLE_NAME'

set pages 20000
SELECT 'ALTER INDEX "' || i.owner || '"."' || i.index_name || '" NOMONITORING USAGE;'
FROM   dba_indexes i
WHERE  owner      = UPPER('&OWNER')
AND    table_name LIKE UPPER('&TABLE_NAME');

undefine OWNER
undefine TABLE_NAME


