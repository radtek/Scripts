prompt abrir arquivo com excel e salvar como xls(compress)
LINESIZE 200 
SET VERIFY OFF 
SET FEEDBACK OFF 
SET PAGESIZE 9999 

SET MARKUP HTML ON ENTMAP ON SPOOL ON PREFORMAT OFF 

SPOOL c:\temp\test_xls.xls 

SELECT object_type 
, SUBSTR( object_name, 1, 30 ) object 
, created 
, last_ddl_time 
, status 
FROM user_objects 
where rownum < 50 
ORDER BY 1, 2 
/ 

SET MARKUP HTML OFF ENTMAP OFF SPOOL OFF PREFORMAT ON	