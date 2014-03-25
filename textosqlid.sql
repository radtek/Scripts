set long 999999
define sql_id=&sql_id

SELECT
         t.sql_text
FROM     v$sqltext t
WHERE    t.sql_id = '&sql_id'
ORDER BY t.piece;

undef sql_id