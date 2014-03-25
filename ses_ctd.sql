
break on "USERNAME" SKIP 1 on "REPORT" SKIP 1
compute SUM LABEL "Total users: " OF "CTD_SESSIONS" ON "USERNAME" 
compute SUM LABEL "Total Geral: " OF "CTD_SESSIONS" ON "REPORT"

SELECT S.USERNAME AS "USERNAME", S.PROGRAM, S.MACHINE, COUNT(1)  "CTD_SESSIONS"
from v$session s
where S.USERNAME is not null
group by s.machine, s.program, s.username
order by 1, 2, 3, 4;

clear breaks
clear computes