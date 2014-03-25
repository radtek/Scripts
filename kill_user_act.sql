select 'alter system kill session '||''''||sid||','||serial#||''''||';' from v$session 
where username = upper('&username')
and status = 'ACTIVE'
order by logon_time
/
