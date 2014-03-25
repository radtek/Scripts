select 'alter system kill session '||''''||sid||','||serial#||''''||';' from v$session 
where username = '&username'
and status = 'ACTIVE'
order by logon_time
/
