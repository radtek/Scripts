set long 999999
SELECT 
         t.sql_text
FROM     DBA_HIST_SQLTEXT t
WHERE    t.sq_hash_value = '&hash'
and rownum =1 ;
/
