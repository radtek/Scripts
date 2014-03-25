select 'alter system kill session '||''''||sid||','||serial#||''''||';' from v$session 
where username = upper('&username')
order by logon_time
/
