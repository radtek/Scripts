/etc/init.d


#!/bin/sh
#
# chkconfig: 345 99 01
# description: starts the oracle dabase deamons ( part of the aD ACS install )
#
# (daemon |action )
echo "Oracle 10g auto start/stop"

ORA_OWNER=oracle
ORACLE_HOME=/usr/local/oracle/product/10.2.0; export ORACLE_HOME
ORA_CRS_HOME=/usr/local/crs
SLEEP_BEFORE_DB=90
LIS_LISTENERS="LISTENER LISTENER1 LISTENER2"
KERNEL_RELEASE=`uname -r`

echo "ORA_OWNER=$ORA_OWNER ORACLE_HOME=$ORACLE_HOME CRS_HOME=$ORA_CRS_HOME KERNEL=$KERNEL_RELEASE"

#
if [ "$1" = "start" ] ; then
   LOG=/tmp/racdb_start.log.`date +'%d%m%y%H%M%S'`
   {

   echo "`date` :-> Mudando owner do /dev/shm p/ oracle"
   chown oracle:dba /dev/shm
   echo "`date` :-> Iniciando HangCheck..."
   insmod /lib/modules/$KERNEL_RELEASE/kernel/drivers/char/hangcheck-timer.ko hangcheck_tick=30 hangcheck_margin=180

   echo " "

   echo "`date` :-> Iniciando Clusterware"
   $ORA_CRS_HOME/bin/crsctl start crs
   echo " "

   echo "`date` :-> Aguardando cluster iniciar para iniciar banco..."

   IND=0
   CRS_STATUS="NOK"
   while [ $IND -lt $SLEEP_BEFORE_DB ] ;
   do
      IND=`expr $IND + 1 `
      $ORA_CRS_HOME/bin/crs_stat -t > /dev/null 2>&1
      if [ $? = 0 ] ; then
         CRS_STATUS="OK"
         IND=$SLEEP_BEFORE_DB
      else
         CRS_STATUS="NOK"
      fi

   done

   echo "`date` :-> Final da inicializacao do CRS"

   if [ $CRS_STATUS = "OK" ] ; then
      echo "CRS iniciado com sucesso. Passa pra inicializacao do db..."
      echo " "
      echo "`date` :-> Iniciando listeners ( $LIS_LISTENERS )"
      for L in $LIS_LISTENERS
      do
         su - $ORA_OWNER -c "$ORACLE_HOME/bin/lsnrctl start $L"
      done
      echo " "
      echo "`date` :-> Iniciando banco Oracle"
      su - $ORA_OWNER -c $ORACLE_HOME/bin/dbstart
      tail -20 $ORACLE_HOME/startup.log
      echo " "
      echo "`date` :-> Iniciando Agent ..."
      su - $ORA_OWNER -c ". /home/oracle/.homeagent; emctl start agent"
      echo " "
   else
      echo "Erro na inicializacao do CRS. Db nao pode ser iniciado."
   fi


   touch /var/lock/subsys/racdb

   } > $LOG 2>&1
   cat $LOG
   exit 0
fi

if [ "$1" = "stop" ] ; then
   LOG=/tmp/racdb_stop.log.`date +'%d%m%y%H%M%S'`
   {
   echo " "
   echo "`date` :-> Parando agent ..."
   su - $ORA_OWNER -c ". /home/oracle/.homeagent; emctl stop agent"
   echo " "
   echo "`date` :-> Parando listeners ( $LIS_LISTENERS )"
   for L in $LIS_LISTENERS
   do
      su - $ORA_OWNER -c "$ORACLE_HOME/bin/lsnrctl stop $L"
   done
   echo " "

   echo "`date` :-> Fechando banco Oracle. Pode levar alguns minutos ..."
   su - $ORA_OWNER -c $ORACLE_HOME/bin/dbshut $ORACLE_HOME
   tail -12 $ORACLE_HOME/shutdown.log
   echo " "

   echo "`date` :-> Finalizando Clusterware"
   $ORA_CRS_HOME/bin/crsctl stop crs
   echo " "

   rm /var/lock/subsys/racdb
   } > $LOG 2>&1
   cat $LOG
   exit 0
fi

if [ "$1" = "status" ] ; then
   RET_GERAL=0

   # Verifica o status do cluster (CRS)
   echo " "
   echo "Verificando status do cluter CRS..."
   $ORA_CRS_HOME/bin/crs_stat -t > /dev/null 2>&1
   if [ ! $? = 0 ] ; then
      echo "Cluster CRS nao ativo"
      echo " "
      RET_GERAL=1
   else
      QSTAT=-u
      AWK=/usr/bin/awk

      # Table header:echo ""
      $AWK \
        'BEGIN {printf "%-45s %-10s %-18s\n", "HA Resource", "Target", "State";
             printf "%-45s %-10s %-18s\n", "-----------", "------", "-----";}'

      # Table body:
      $ORA_CRS_HOME/bin/crs_stat $QSTAT | $AWK \
      'BEGIN { FS="="; state = 0; }
      $1~/NAME/ && $2~/'$RSC_KEY'/ {appname = $2; state=1};
      state == 0 {next;}
      $1~/TARGET/ && state == 1 {apptarget = $2; state=2;}
      $1~/STATE/ && state == 2 {appstate = $2; state=3;}
      state == 3 {printf "%-45s %-10s %-18s\n", appname, apptarget, appstate; state=0;}'

      echo " "
      echo "Cluster CRS ativo nessa maquina."
      echo " "
   fi

   echo "Verificando status da Instance Oracle..."
   su - $ORA_OWNER -c $ORACLE_HOME/bin/dbstatus > /dev/null 2>&1
   if [ ! $? = 0 ] ; then
      echo "Instance Oracle nao ativa."
      echo " "
      RET_GERAL=1
   else
      echo " "
      echo "Instance Oracle ativa nessa maquina."
      ps -ef | grep pmon | grep -v grep
      echo " "
   fi

   echo "Verificando Listeners ( $LIS_LISTENERS )"
   for L in $LIS_LISTENERS
   do
      su - $ORA_OWNER -c "$ORACLE_HOME/bin/lsnrctl status $L" > /dev/null 2>&1
      if [ ! $? = 0 ] ; then
         echo "Erro acessando listener $L"
         echo " "
         RET_GERAL=1
      else
         echo " "
         echo "Listener $L: OK"
         echo " "
      fi
   done
   echo "Verificando agent..."
   su - $ORA_OWNER -c ". /home/oracle/.homeagent; emctl status agent"
   if [ ! $? = 0 ] ; then
      echo "Erro testando agent"
      echo " "
      RET_GERAL=1
   else
      echo "Agent OK."
      echo " "
   fi
   echo " "

   exit $RET_GERAL

fi

echo "Usage: $0 [start|stop|status]"


