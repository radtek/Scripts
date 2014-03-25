
break on "USERNAME" SKIP 1 on "REPORT" SKIP 1
compute SUM LABEL "Total users: " OF "CTD_SESSIONS" ON "USERNAME" 
compute SUM LABEL "Total Geral: " OF "CTD_SESSIONS" ON "REPORT"


SELECT S.USERNAME AS "USERNAME", S.INST_ID, S.PROGRAM, DECODE(S.server, 'NONE', 'SHARED', Server) as server, COUNT(1)  "CTD_SESSIONS"
from gv$session s
where S.USERNAME is not null
group by S.USERNAME, S.INST_ID, S.PROGRAM, DECODE(S.server, 'NONE', 'SHARED', s.Server)
order by 1, 2, 3, 4;

clear breaks
clear computes