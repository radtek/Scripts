col MEMBER FORMAT a100
break on thread# skip 1

select g.thread#, M.GROUP#, M.member, round(G.BYTES / 1024 / 1024) size_mb, g.STATUS, g.archived
from v$log g 
  join V$LOGFILE M 
    on M.GROUP#=G.GROUP# 
order by g.thread#, m.group#,m.member;
