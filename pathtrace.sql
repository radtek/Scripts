accept sid prompt "Informe SID ou 0 para todos: " default 0
accept username prompt "Informe uername ou '' para todos: " default ''

select c.value || '/' || d.instance_name || '_ora_' || a.spid || '.trc' trace_file_is_here
from v$process a, v$session b, v$parameter c, v$instance d
where a.addr = b.paddr
and b.audsid = userenv('sessionid')
and c.name = 'user_dump_dest' 
and (b.sid = &&sid or &&sid = 0)
and (b.username = '&&username' or '&&username' = '');

undef sid
undef username