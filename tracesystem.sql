


set serveroutput on
set verify off
define sid=&sid
define serial=&serial

select  
	'exec sys.dbms_system.set_bool_param_in_session(&sid,&serial, ''timed_statistics'',true);' || CHR(10)||CHR(13) ||
	'exec sys.dbms_system.set_int_param_in_session (&sid,&serial, ''max_dump_file_size'',2147483647);'  || CHR(10)||CHR(13) ||
	'exec sys.dbms_system.set_bool_param_in_session(&sid,&serial, ''sql_trace'', TRUE); '
from v$session
where sid=&sid
 and serial#=&serial;

undef sid
undef serial
set verify on
set serveroutput off