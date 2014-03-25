prompt **********************
prompt algumas vezes no Oracle 9i as sessões ficam como KILLED, então se dedicated é necessário matar no SO também
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
