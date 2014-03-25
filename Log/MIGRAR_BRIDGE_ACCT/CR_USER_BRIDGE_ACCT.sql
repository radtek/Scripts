CREATE USER BRIDGE_ACCT identified by values  '9A9E1561B8401D34' 
default tablespace BRIDGE_ACCT_DATA
temporary tablespace "TEMP";
grant connect, resource, QUERY REWRITE to BRIDGE_ACCT;
grant CREATE VIEW to BRIDGE_ACCT;
grant CREATE TABLE  to BRIDGE_ACCT;
grant ALTER SESSION to BRIDGE_ACCT;
grant CREATE CLUSTER to BRIDGE_ACCT;
grant CREATE SESSION to BRIDGE_ACCT;
grant CREATE SYNONYM to BRIDGE_ACCT;
grant CREATE SEQUENCE to BRIDGE_ACCT;
grant CREATE DATABASE LINK to BRIDGE_ACCT;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_DATA;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_INDX;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_ACCT_HIST_DATA;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_ACCT_HIST_DATA01;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_ACCT_HIST_DATA02;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_ACCT_HIST_DATA03;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_ACCT_HIST_DATA04;
alter user BRIDGE_ACCT quota unlimited on BRIDGE_ACCT_ACCT_HIST_INDX;
revoke unlimited tablespace from BRIDGE_ACCT; 
commit;