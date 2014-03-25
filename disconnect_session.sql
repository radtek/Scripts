select 'ALTER SYSTEM DISCONNECT SESSION ''' || to_char(a.sid) || ',' || to_char(a.serial#) || ''' IMMEDIATE;'
from v$session a, v$process b
where a.username is not null
  and a.paddr = b.addr
  and round(last_call_et/60) > 5
  and a.username = 'IBOXNET'



select a.username,(round(last_call_et/60)) "Idle - min", count(1)
from v$session a, v$process b
where a.paddr = b.addr
  and a.username = 'IBOXNET'
group by a.username, (round(last_call_et/60))
order by 1, 2, 3