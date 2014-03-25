
set verify off

prompt sid e serial NULL trace da sessão atual
prompt serial NULL trace do sid independente do serial
prompt se usa shared server: trcsess  output=tracefile.trc session=session_id.serial 
define sid=&sid
define serial=&serial

accept waits char prompt 'Gerar com waits [true|false]:'  default 'true'
accept binds char prompt 'Gerar com binds [true|false]:'  default 'true'

select  
	'exec sys.dbms_monitor.session_trace_enable(&&sid,&&serial, waits=>&waits,binds=>&binds);' || chr(10) || chr(13) ||
	'exec sys.dbms_monitor.session_trace_disable(&&sid,&&serial);'
from dual;

undef sid
undef serial
undef waits
undef binds
set verify on
