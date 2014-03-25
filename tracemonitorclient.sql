
set verify off

prompt aplicativo deve executar: exec dbms_session.set_identifier('APLICATIVOX');

define application=&application

accept waits char prompt 'Gerar com waits [true|false]:'  default 'true'
accept binds char prompt 'Gerar com binds [true|false]:'  default 'true'

select  
	'exec sys.dbms_monitor.client_id_trace_enable(''&application'', waits=>&waits,binds=>&binds);' || chr(10) || chr(13) ||
	'exec sys.dbms_monitor.client_id_trace_disable(''&application'');'
from dual;

undef sid
undef serial
undef waits
undef binds
set verify on
