set long 999999
define sql_id=&sql_id

SELECT 
         t.sql_text
FROM     DBA_HIST_SQLTEXT t
WHERE    t.sql_id = '&sql_id'
and rownum =1 ;
undef sql_id