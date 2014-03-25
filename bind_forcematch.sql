prompt ###### lista sql com mesmo codigo e que poderia utilizar bind #########
set pages 1000
set lines 100

column schema format a20
column sql_text format a80 
WITH force_matches_sql AS
       (SELECT force_matching_signature,
               COUNT( * )  matches_sql,
               MAX(sql_id || child_number) max_sql_child,
               DENSE_RANK() OVER (ORDER BY COUNT( * ) DESC)
                  ranking
        FROM v$sql
        WHERE force_matching_signature <> 0
          AND parsing_schema_name <> 'SYS'
        GROUP BY force_matching_signature
        HAVING COUNT( * ) > 5)
SELECT sql_id,  matches_sql, parsing_schema_name schema, sql_text
  FROM    v$sql JOIN force_matches_sql
    ON (sql_id || child_number = max_sql_child)
WHERE ranking <= 10
ORDER BY matches_sql DESC; 