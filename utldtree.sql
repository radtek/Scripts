
prompt ***requisito 
prompt    - executar como SYSTEM @/usr/local/oracle/product/10.2.0/rdbms/admin/utldtree.sql
EXECUTE deptree_fill(UPPER('&object_type'), UPPER('&owner'), UPPER('&object_name'));
SELECT * FROM deptree;
SELECT * FROM ideptree;
