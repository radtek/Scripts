
PROMPT ##### SESSOES TOTAIS #############
SELECT  vs.type,
	substr(n.name,1,25) memory, 
	sum(ROUND(s.value/1024/1024)) as sumMB, 
	min(ROUND(s.value/1024/1024)) as minMB,
	max(ROUND(s.value/1024/1024)) as maxMB,
	avg(ROUND(s.value/1024/1024)) as avgMB
FROM v$sesstat s, v$statname n, v$process p, v$session vs
WHERE s.statistic# = n.statistic#
AND n.name LIKE '%pga memory%'
AND s.sid=vs.sid
AND vs.paddr=p.addr
group by vs.type, substr(n.name,1,25) 
order by memory;




PROMPT ###### QUANTIDADE SESSOES POR MB UTILIZADO #############
select vs.type, count(1) ctd, ROUND(s.value/1024/1024), count(1) * ROUND(s.value/1024/1024) total_range_MB
FROM v$sesstat s, v$statname n, v$process p, v$session vs
WHERE s.statistic# = n.statistic#
AND n.name LIKE 'session pga memory'
AND s.sid=vs.sid
AND vs.paddr=p.addr
group by vs.type, ROUND(s.value/1024/1024)
having count(1) > 1 
order by 1, 2 desc;



PROMPT ######## SESSOES COM MAIS DE 10 MB #############
SELECT p.spid, s.sid, substr(n.name,1,25) memory, ROUND(s.value/1024/1024) as MBytes
FROM v$sesstat s, v$statname n, v$process p, v$session vs
WHERE s.statistic# = n.statistic#
AND n.name LIKE 'session pga memory'
AND s.sid=vs.sid
AND vs.paddr=p.addr
AND s.value > 10000000 /* --remove this line to view all process size */
order by spid,memory;


PROMPT ######### TOTAL UTILIZADO PROCESSOS ORACLE ##############
select ROUND(sum(s.value/1024/1024))
FROM v$sesstat s, v$statname n, v$process p, v$session vs
WHERE s.statistic# = n.statistic#
AND n.name LIKE 'session pga memory'
AND s.sid=vs.sid
AND vs.paddr=p.addr
and vs.type = 'BACKGROUND';



PROMPT ############# TOTAL POR USUARIO ###############

SELECT sum(ROUND(s.value/1024/1024)) as MBytes, vs.username
FROM v$sesstat s, v$statname n, v$process p, v$session vs
WHERE s.statistic# = n.statistic#
AND n.name LIKE 'session pga memory'
AND s.sid=vs.sid
AND vs.paddr=p.addr
and vs.type <> 'BACKGROUND'
group by vs.username
order by 1;

PROMPT ############# CONEXOES TOTAIS - USER ###############
select username, count(1) CTD
from v$session
group by username
order by CTD desc;

PROMPT ############# CONEXOES TOTAIS - MACHINE ###############
select machine, count(1) CTD
from v$session
group by machine
order by CTD desc;