set lines 1000
set pages 1000
set echo on 
column in_cached_plan format a16


WITH in_plan_objects AS
     (SELECT DISTINCT object_name
                 FROM v$sql_plan
                WHERE object_owner = USER)
SELECT table_name, index_name,
       CASE WHEN object_name IS NULL
            THEN 'NO'
            ELSE 'YES'
       END AS in_cached_plan
  FROM user_indexes LEFT OUTER JOIN in_plan_objects
       ON (index_name = object_name); 
