set long 99999
format sql_id a15
DEFINE sqltext=&sqltext

SELECT sql_id, child_number, SQL_TEXT, EXECUTIONS
FROM v$sql 
WHERE sql_text LIKE '&sqltext';


UNDEFINE sqltext