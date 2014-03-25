set ver off;
accept new_user prompt 'New user............:'
Accept pass     prompt 'Password............:'
accept def_tbl  prompt 'Default tablespace..:'
accept idx_tbl  prompt 'Index tablespace....:'
accept tem_tbl  prompt 'Temporary tablespace:'
create user &new_user identified by &pass
default tablespace &def_tbl
temporary tablespace &tem_tbl;
grant connect, resource, QUERY REWRITE to &new_user;
grant CREATE VIEW to &new_user;
grant CREATE TABLE  to &new_user;
grant ALTER SESSION to &new_user;
grant CREATE CLUSTER to &new_user;
grant CREATE SESSION to &new_user;
grant CREATE SYNONYM to &new_user;
grant CREATE SEQUENCE to &new_user;
grant CREATE DATABASE LINK to &new_user;
alter user &new_user quota unlimited on &def_tbl;
alter user &new_user quota unlimited on &idx_tbl;
prompt somente no 10g
revoke unlimited tablespace from &new_user; 
commit;