
set serveroutput on
def banco=&banco
def user=&user
set time on
set serveroutput on
col host_name format a30
connect &user@&banco
col force_matching_signature for 99999999999999999999999999999999999
col exact_matching_signature for 99999999999999999999999999999999999
col sid for 99999999999999999
set sqlprom '&banco>'
set line 600
set pages 100
alter session set nls_Date_format = 'dd/mm/rrrr hh24:mi:ss';
alter session set statistics_level= all;
alter session set nls_sort= binary;
select a.name, b.* 
 from v$database a, v$instance b;
undef banco
undef user

@@sesinfo


