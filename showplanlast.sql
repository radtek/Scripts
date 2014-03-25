SET serveroutput OFF
SET LINESIZE 200
SELECT * FROM TABLE(DBMS_XPLAN.display_cursor);
SET serveroutput on