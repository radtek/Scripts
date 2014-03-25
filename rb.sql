set echo on
drop index hr.EMP_SALARY_IX;
ANALYZE TABLE hr.departments DELETE STATISTICS;
set echo off