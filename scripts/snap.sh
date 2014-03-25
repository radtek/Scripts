#Script para diagnosticar problemas de contencao.
# agendar para a cada 2 minutos na crontab do oracle
# */2 * * * * /home/oracle/ilegra/snap/snap.sh orahlg01 1>/dev/null 2>/dev/null
# Especificar aqui o diretorio onde os logs diarios serao gerados.
DIR_LOG=/home/oracle/ilegra/snap/logs/$1

# Especificar aqui o caminho e nome completo do arquivo com as variaveis de ambiente do Oracle.
VAR_AMB=/home/oracle/ilegra/snap/$1

#Remove logs com mais de 20dias
find $DIR_LOG -name 'snap*.log' -ctime +20 -exec rm -f {} \;

if [ ! -z ${VAR_AMB} ] ; then
   . ${VAR_AMB}
fi

export NLS_DATE_FORMAT='dd/mm/rrrr hh24:mi:ss';
LOG=${DIR_LOG}/snap_${ORACLE_SID}_`date +'%Y-%m-%d'`.log


{
echo " "
echo " "
echo "###################################"
echo "Inicio da coleta:"
echo "----------------"
date
echo " "
echo " "
echo "Saida do TOP....:"
echo "----------------"
top -b -d 2 -n 1 -c > /tmp/top.out ; head -20 /tmp/top.out
top -b -d 2 -n 1 -c > /tmp/top.out ; head -20 /tmp/top.out

echo " "
echo "Saida do vmstat:"
echo "----------------"
vmstat 1 10

echo " "
echo "Saida do multipath:"
echo "----------------"
#multipath -ll
#sudo /sbin/multipath -ll

echo " "
echo "Saida do free:"
echo "----------------"
free

echo " "
echo "Saida do meminfo:"
echo "----------------"
cat /proc/meminfo

echo " "
echo "Saida do Banco.:"
echo "----------------"
sqlplus -s /nolog <<eof
conn / as sysdba
set lines 200
set pages 200
set trimspool on



Prompt ASM Disk Stat:
select * from v\$asm_disk_stat;



Prompt Eventos:
col Username for a13;
col event for a25 trunc;
col sec for 999
col osuser for a18
col spid for a6
col sid  for 999999
col module for a25
col HASH_VALUE for a15

select /*+ Rule */
       c.spid,
       b.sid,
       decode(b.username,null,'ora_'||substr(b.program,instr(b.program,'(')+1,4),b.username) username,
       a.event,
       'HV='||to_char(b.sql_hash_value) HASH_VALUE ,
        'HV='||to_char(b.prev_hash_value) PREV_HASH_VALUE ,
       a.p1,a.p2,a.p3,
       a.seconds_in_wait sec
from v\$session_wait a,v\$session b, v\$process c
where a.event not like '%rdbms ipc message%'
  and a.event not like '%smon timer%'
  and a.event not like '%pmon timer%'
  and a.event not like '%jobq slave wait%'
  and a.event not in ('Streams AQ: qmn slave idle wait','DIAG idle wait')
  and a.event not like 'Streams AQ:%'
  and a.event not like '%ges remote message%'
  and a.event not like '%gcs remote message%'
  and a.sid=b.sid
  and b.paddr=c.addr
  and b.status ='ACTIVE'
order by b.sql_hash_value,b.sid;


col Name for a28;
col lmode for a4;
col request for a4;
col MODULE for a20;
Prompt Locks:
select  /*+ rule */
       a.sid,b.username,a.type,d.name||'.'||c.name name, a.id1, a.id2,
       decode(lmode,1,'null',2,'RS',3,'RX',4,'S',5,'SRX',6,'X',0,'NONE',lmode) lmode,
       decode(request,1,'null',2,'RS',3,'RX',4,'S',5,'SRX',6,'X',0,'NONE',request)
request,b.module
  from v\$lock a, v\$session b, sys.obj\$ c,sys.user\$ d
 where a.id1 = c.OBJ# (+)
   and a.sid = b.sid
   and c.owner# = d.user# (+)
   and b.username is not null
 order by 1;

Prompt Blocking:
col lmode for 99
col request for 99
select /*+ RULE ordered */ DECODE( l.block, 0, '       ','YES    ') BLOCKER,
        DECODE( l.block, 0, 'YES    ','       ') WAITER,
        l.SID, s.username, s.sql_hash_value,s.status,s.machine,l.TYPE, l.ID1, l.ID2, l.LMODE, l.REQUEST, l.CTIME, l.BLOCK, s.program, s.module
from v\$lock l, v\$session s
where l.sid = s.sid
and (l.ID1,l.ID2,l.TYPE) in
(select l.ID1,l.ID2,l.TYPE from v\$lock l where request>0)
order by id1,id2,waiter;

Prompt Active:
col MACHINE for a23
col PROGRAM for a20
select a.sid,a.username,last_call_et/60 "Idle - min",a.sql_hash_value,
 osuser,a.machine,a.program,a.status,logon_time,server
 from v\$session a, v\$process b
 where a.username is not null
 and a.paddr = b.addr
 and status = 'ACTIVE'
 order by 5;

Prompt PGAs:
break on report;
col program for a25 trunc
compute sum of TAM_PGA_KB on report;
Select * from (
select b.sid, c.username, c.osuser, c.program, To_char(c.logon_time,'dd/mm/yyyy hh24:mi:ss') Ltime,round(b.value/1024) Tam_pga_Kb
  from v\$statname a, v\$sesstat b, v\$session c
 where a.STATISTIC# = b.STATISTIC#
   and b.sid        = c.sid
   and (a.name      = 'session pga memory' )
 ORDER BY Tam_pga_Kb Desc)
 Where Rownum <= 10;

Select 'Total_PGA: '||To_char(Sum(round(b.value/1024))) Total_PGA
  from v\$statname a, v\$sesstat b, v\$session c
 where a.STATISTIC# = b.STATISTIC#
   and b.sid        = c.sid
   and (a.name      = 'session pga memory' );

break on report
compute sum of Nro_Sessoes oN report;

Prompt Conexoes_Por_Server
Select Server, Count(*) from v\$Session group by Server;

Prompt Conexoes_Top_Users:
Select * from (
Select Username, count(*) Nro_Sessoes from v\$Session group by username order by 2
desc)
where rownum <= 10;

Prompt Conexoes_Top_Machine_Server:
Col Machine for a20
Select * from (
Select Machine, Server, count(*) Nro_sessoes from v\$Session group by Machine,Server
order by 3 Desc)
where rownum <= 10;

Prompt Utilizacao de Temp:
BREAK ON report;
COMPUTE SUM OF KBytes_usando ON report;
COl TBS for a15
---
Select a.Tablespace_name TBS, a.Current_Users,
       Round((a.total_blocks * b.block_size)/1024/1024)    MB_Segment,
       Round((a.Used_blocks * b.block_size)/1024/1024)     MB_Em_Uso,
       Round((a.Free_blocks * b.block_size)/1024/1024)     MB_Livre,
       Round((a.Max_blocks * b.block_size)/1024/1024)      MB_Maximo,
       Round((a.Max_sort_blocks * b.block_size)/1024/1024) MB_Maximo_Individual
  from v\$sort_segment a, dba_tablespaces b
 where a.tablespace_name = b.tablespace_name;

SELECT /*+ Ordered use_nl(u,s,t) */
       s.sid, s.username, u.tablespace TBS, u.segtype, u.extents,
       (u.blocks * (select value from v\$parameter where name = 'db_block_size'))
/1024/1024 MB_usando,
       (select sum(f.bytes) from dba_temp_files f where f.tablespace_name =
u.tablespace) /1024/1024 Total_temp_mb
FROM v\$sort_usage u, v\$session s
WHERE s.saddr      = u.session_addr
order by S.sid;

Exit;
eof

echo " "
echo "Final da coleta:"
echo "----------------"
date
echo " "

} >> $LOG 2>&1

echo "`date` -> Gerado snap no arquivo $LOG"

                                 	