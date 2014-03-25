# Script que realiza o crosscheck entre o catalogo do Midia Server (netbackup) e o Rman.
# Instancia as variaveis de ambiente
. /home/oracle/.bash_profile

DATA=`date +'%Y%m%d'`
TIME=`date +'%H%M%S'`
LOG=$ADM/logs/especial_crosscheck.log.${DATA}_${TIME}
NRO_DIAS_RETENCAO=$1

if [ -z "$2" ] ; then
   DBNAME=${ORACLE_SID}
else
   DBNAME=$2
fi

. $ADM/backup/bkp_${ORACLE_SID}.conf

echo "`date` -> Inicio da execucao. DBNAME: $DBNAME"

{

date
echo "-------------------------------------------------------"
$ORACLE_HOME/bin/rman target / catalog ${CONEXAO_RMAN} <<eof
allocate channel for maintenance type 'sbt';
crosscheck backup completed before 'sysdate - ${NRO_DIAS_RETENCAO}';
exit;
eof
RET_RMAN=$?
echo "-------------------------------------------------------"
date

echo " "
echo "-------------------------------------------------------"
echo "Realiza um resync entre o controlfile e o catalogo"
$ORACLE_HOME/bin/rman target / catalog ${CONEXAO_RMAN} <<eof
resync catalog;
exit;
eof
echo "-------------------------------------------------------"
date

echo " "
echo "-------------------------------------------------------"
echo "Chama procedure para remover os BackupSets expirados."
$ORACLE_HOME/bin/sqlplus -s /nolog <<eof
whenever sqlerror exit 1;
whenever oserror  exit 2;
set lines 100
set serveroutput on size 1000000;
conn ${CONEXAO_RMAN}
var ret varchar2(500);
exec pkg_clean_rman_catalog.PRC_CLEAN_ALL_EXPIRED ('${DBNAME}',:ret);
print
eof
RET_PLUS=$?

echo "-------------------------------------------------------"
date
echo " "
} >> $LOG 2>&1

NRO_CROSS=`grep "backup piece handle" $LOG | wc -l`
NRO_EXPIR=`grep "found to be 'EXPIRED'" $LOG | wc -l`
NRO_AVALI=`grep "found to be 'AVAILABLE'" $LOG | wc -l`
RET_PROCE=`grep "Nro de linhas excluidas" $LOG`

RET=0
if [ $RET_RMAN = 0 ] ; then
   echo "RMAN crosscheck executado com sucesso !"
else
   echo "RMAN crosscheck executado com erro."
   RET=$RET_RMAN
fi

echo " "
echo "Nro de BackupSets Verificados:$NRO_CROSS"
echo "Nro de BackupSets Expirados..:$NRO_EXPIR"
echo "Nro de BackupSets Disponiveis:$NRO_AVALI"
echo "Mensagem de retorno da proc..:"
echo "$RET_PROCE"
echo " "

if [ $RET_PLUS = 0 ] ; then
   echo "SQLPLUS delete expired backups executado com sucesso !"
else
   echo "SQLPLUS delete expired backups executado com erro."
   RET=$RET_PLUS
fi


echo "`date` -> Final da execucao. Log gerado em:"
echo "$LOG"
exit $RET

