prompt **********************
prompt algumas vezes no Oracle 9i as sess�es ficam como KILLED, ent�o se dedicated � necess�rio matar no SO tamb�m
prompt **********************
prompt kill BD
prompt **********************
select 'alter system kill session '''||a.sid||','||a.serial#||''' immediate;'
from  v$session a, v$process b
where a.SID in (&SID)
and a.paddr= b.addr
/
prompt **********************
prompt kill SO
prompt **********************
select 'kill -9 ' || b.spid
from  v$session a, v$process b
where a.SID in (&SID)
and a.paddr= b.addr
and upper(a.status) = 'KILLED'
and (server is null or server  = 'DEDICATED')
/
