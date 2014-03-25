set long 999999
col hash_value  format 99999999999
define sql_hash_value=&sql_hash_value

SELECT
         t.sql_text
FROM     v$sqltext t
WHERE    t.hash_value = &sql_hash_value 
ORDER BY t.piece;

undef sql_hash_value