# Script usado p/ extrair historico de carga do sistema e diagnosticar o problema ORA-12540
LOG=/o01/app/oracle/admin/oradb1/udump/diag_`date +'%Y%m%d'`.txt
INICIO=`date +'%d/%m/%Y %H:%M:%S'`
{
echo "*************************************************"
echo "Inicio da coleta:$INICIO"

echo " "
echo "TOP:"
top -b -n1 | head -40


echo " "
echo "VMSTAT:"
vmstat 5 5

echo " "
echo "SAR (CPU):"
sar -u 5 5

echo " "
echo "IPCS:"
ipcs -a

echo " "
echo "BACKGROUND PROCESS:"
ps -efl | grep ora_ | grep -v grep

echo " "
echo "NRO TOTAL DE PROCESSOS:"
ps -ef |  grep -v grep | wc -l


echo " "
echo "NRO DE PROCESSOS ORACLE:"
ps -ef | grep ora | grep -v grep | wc -l

echo " "
echo "DADOS DO BANCO:"
sqlplus bkp/bkporadb1 <<eof
break on report;
compute sum of nro_ses on report;
set pages 200;
set lines 200;
col username for a20 trunc;
col event for a50 trunc;
Prompt Sessions:
select server, count(*) NRO_SES from v\$session group by server;
Prompt Processes:
select count(*) Nro_procs from v\$process;
Prompt Events:
select b.username,
       a.event,
       a.p1,
       a.p2,
       a.p3,
       a.seconds_in_wait,
       a.state
from v\$session_wait a,v\$session b
where event not like '%message from%'
  and event not like '%SQL*Net%'
  and event not like '%rdbms ipc message%'
  and event not like '%timer%'
  and a.sid=b.sid
order by b.username;
exit;
eof
echo " "
echo " "
echo "FINAL"
} >> $LOG 2>&1

# Grava no banco a quanto de memoria usada pela "aplicacao"
#DIAGFILE=$LOG
#APPMEM=`tail -180 $DIAGFILE | grep "Application:" | awk '{print $2}' `
#sqlplus bkp/bkporadb1 <<eof
#insert into monitora_mem (data,app_mem_mb) values (sysdate,$APPMEM);
#commit;
#exit;
#eof
