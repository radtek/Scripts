SET LONG 1000000
SET LONGCHUNKSIZE 1000000

SELECT DBMS_SQLTUNE.report_sql_detail(
  sql_id       => '&sqlid',
  type         => 'ACTIVE',
  report_level => 'ALL') AS report
FROM dual;
