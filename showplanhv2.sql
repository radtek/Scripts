   

@plusenv
undef sql_hash_value

col hash_value  format 99999999999
col sql_text    format a64 word_wrapped
break on hash_value

SELECT
         t.sql_text
FROM     v$sqltext t
WHERE    t.hash_value = &&sql_hash_value
ORDER BY t.piece
;

SET ECHO OFF
SELECT LPAD( '  ', 2 * ( LEVEL - 1 ) ) ||
       DECODE( id, 0, operation || '  (Cost = ' || position || ')',
       LEVEL - 1 || '.' || NVL( position, 0 ) ||
       '  ' || operation ||
       '  ' || options ||
       '  ' || object_name ||
       '  ' || object_node ) "Query Plan"
FROM (select distinct id,parent_id, operation,cost, position,options,object_name,object_node
      FROM v$sql_plan
      where hash_value = '&&sql_hash_value')
START WITH id = 0
CONNECT BY PRIOR id = parent_id
/

undef sql_hash_value

