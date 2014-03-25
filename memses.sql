col sid format 999999
col program format a20

select b.sid, c.username, c.osuser, c.program, round(b.value/1024) Tam_pga_Kb, c.logon_time, c.last_call_et, c.status,c.server
from v$statname a, v$sesstat b, v$session c
where a.STATISTIC#= b.STATISTIC#
  and b.sid=c.sid
--  and c.server = 'DEDICATED'
  and (a.name = 'session uga memory' )
ORDER BY b.value;