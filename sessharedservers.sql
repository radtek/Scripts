prompt SHARED SERVERS LIST
select p.pid, p.spid, s.* from v$shared_server s inner join v$process p on p.ADDR = s.PADDR;

prompt 
prompt 
prompt DISPATCHERS LIST

select p.pid, p.spid, s.* from V$DISPATCHER s inner join v$process p on p.ADDR = s.PADDR;