


set serveroutput on
set verify off
set feedback off

exec dbms_output.put_line('event code 10046 - oracle kernel must emit trace lines and timings ($ORACLE_HOME/rdmbs/mesg/oraus.msg)');
exec dbms_output.put_line('Level 0 = No statistics generated ');
exec dbms_output.put_line('Level 1 = standard trace output including parsing, executes and fetches plus more. ');
exec dbms_output.put_line('Level 2 = Same as level 1. ');
exec dbms_output.put_line('Level 4 = Same as level 1 but includes bind information ');
exec dbms_output.put_line('Level 8 = Same as level 1 but includes wait''s information ');
prompt Level 12 = Same as level 1 but includes binds and waits

define sid=&sid
define serial=&serial
accept lvl number default 1 prompt 'informe o level: '
set feedback on

select  
	'exec sys.dbms_system.set_bool_param_in_session(&sid,&serial, ''timed_statistics'',true);' || CHR(10)||CHR(13) ||
	'exec sys.dbms_system.set_int_param_in_session (&sid,&serial, ''max_dump_file_size'',2147483647);'  || CHR(10)||CHR(13) ||
	'exec sys.dbms_system.set_ev(&sid,&serial,10046,&lvl,'''');'	
from v$session
where sid=&sid
 and serial#=&serial;

undef sid
undef serial
undef lvl
set verify on
set serveroutput off
