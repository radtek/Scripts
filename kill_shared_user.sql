select 'alter system disconnect session ''' || sid || ',' || serial# || ''' immediate;'  from v$session where username = upper('&username')
/
