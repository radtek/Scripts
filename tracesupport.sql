
set verify off

prompt instalar pacote em: $ORACLE_HOME\rdbms\admin\dbmssupp.sql

define sid=&sid
define serial=&serial
accept waits char prompt 'Gerar com waits [true|false]:'  default 'true'
accept binds char prompt 'Gerar com binds [true|false]:'  default 'true'

select  
	'exec sys.dbms_support.start_trace_in_session(&sid,&serial, waits=>&waits,binds=>&binds);' 
from v$session
where sid=&sid
and serial#=&serial;

undef sid
undef serial
undef waits
undef binds
set verify on
