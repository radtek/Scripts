set pages 2000
break on "INST_ID" SKIP 1 on "USERNAME" SKIP 1 
compute SUM LABEL "Total Users " OF "CTD_SESSIONS" ON "USERNAME" 
compute SUM LABEL "Total Geral " OF "CTD_SESSIONS" ON "INST_ID"

SELECT S.INST_ID, S.USERNAME AS "USERNAME", S.PROGRAM, S.MACHINE, COUNT(1)  "CTD_SESSIONS"
from gv$session s
where S.USERNAME is not null
group by S.INST_ID, s.machine, s.program, s.username
order by 1, 2, 3, 4, 5;

clear breaks
clear computes