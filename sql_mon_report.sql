SET lines 2000
SET pages 1000
SET LONG 999999
SET longchunksize 250
SELECT dbms_sqltune.report_sql_monitor(sql_id=>'&sqlid',sql_exec_id=>&exec_id,sql_exec_start=> TO_DATE('&exec_start','dd-mm-yyyy hh24:mi:ss'),report_level=>'ALL') AS report FROM dual;
