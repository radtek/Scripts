set echo on

CREATE INDEX HR.EMP_SALARY_IX
ON HR.EMPLOYEES(SALARY DESC, HIRE_DATE)
NOLOGGING
TABLESPACE "USERS";
EXEC DBMS_STATS.GATHER_TABLE_STATS ('HR', 'EMPLOYEES');

set echo off