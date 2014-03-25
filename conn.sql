set feedback on
set serveroutput on
def banco=&banco
set time on
set serveroutput on
--SET SQLBLANKLINES ON  
col host_name format a30
col sid format 99999999999999999
col force_matching_signature for 99999999999999999999999999999999999
col exact_matching_signature for 99999999999999999999999999999999999
col signature  for 99999999999999999999999999999999999
connect system@&banco
set sqlprom '&banco>'
set line 600
set pages 100
$chcp 1252
alter session set nls_sort = BINARY;
alter session set nls_Date_format = 'dd/mm/rrrr hh24:mi:ss';
alter session set statistics_level= all;
select * from v$version;
select a.name, b.* 
 from v$database a, v$instance b;
undef banco
@@sesinfo.sql
