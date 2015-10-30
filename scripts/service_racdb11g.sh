#!/bin/sh
#
# chkconfig: 345 99 01
# description: starts the oracle dabase deamons ( part of the aD ACS install )
#
# (daemon |action )
echo "Oracle 11g auto start/stop/status"

ORA_OWNER=oracle
ORACLE_HOME=/usr/local/oracle/product/11.2.0.4; export ORACLE_HOME
ORA_CRS_HOME=/usr/local/crs
SLEEP_BEFORE_DB=90
LIS_LISTENERS="LISTENER"
KERNEL_RELEASE=`uname -r`
DB_NAME=cont11g
INST_NAME=cont11g2

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

                MX_TRY=10
            CTD=1
        while [ $CTD -le $MX_TRY ] ;
                do
                        CRS_STATUS=`$ORA_CRS_HOME/bin/crsctl check crs` > /dev/null 2>&1
                        echo $CRS_STATUS | grep "CRS-4537" > /dev/null 2>&1
                        if [ $? = 0 ] ; then
                        CTD=10
                    echo "CRS START OK..."
                        else

                        sleep 10

                        fi

                        (( CTD++ ))
                done



#################################################
#       Startup oracle 11g, adicionado por:
#       Hermes Pimentel
#       16/04/2013
#################################################

        sleep 130
                echo "Iniciando Database..."
                DB_STATUS=`$ORA_CRS_HOME/bin/srvctl status instance -d $DB_NAME -i $INST_NAME` > /dev/null 2>&1
                echo $DB_STATUS | grep "is running on node" > /dev/null 2>&1
                        if [ $? = 0 ] ; then
                                        echo " "
                                        echo "DATABASE ATIVA"
                                        echo $DB_STATUS
                                        echo " "
                                        echo " "
                        else
                                        $ORA_CRS_HOME/bin/srvctl start instance -d $DB_NAME -i $INST_NAME
                                        DB_STATUS=`$ORA_CRS_HOME/bin/srvctl status instance -d $DB_NAME -i $INST_NAME` > /dev/null 2>&1
                                        echo $DB_STATUS | grep "is running on node" > /dev/null 2>&1
                                                if [ $? = 0 ] ; then
                                                        echo " "
                                                        echo "DATABASE ATIVA"
                                                        echo $DB_STATUS
                                                        echo " "
                                                        echo " "
                                                else
                                                        echo " "
                                                        echo " FALHA AO INICIAR DATABASE " $INST_NAME
                                                        echo $DB_STATUS
                                                        echo " "
                                                        echo " "
                                                fi
                        fi

   echo "`date` :-> Final da inicializacao do CRS e DATABASE"

#####################################################################################
#       O listener esta atrelado ao serviÃ§o do cluster e subirÃ¡ automaticamente com o CRS
#       Modificado por Hermes Pimentel, 16/04/2013
#####################################################################################


#   if [ $CRS_STATUS = "OK" ] ; then
#      echo "CRS iniciado com sucesso. Passa pra inicializacao do db..."
#      echo " "
#      echo "`date` :-> Iniciando listeners ( $LIS_LISTENERS )"
#      for L in $LIS_LISTENERS
#      do
#        su - $ORA_OWNER -c "$ORACLE_HOME/bin/lsnrctl start $L"
#      done
#      echo " "
#      echo "`date` :-> Iniciando banco Oracle"
#      su - $ORA_OWNER -c $ORACLE_HOME/bin/dbstart
#      tail -20 $ORACLE_HOME/startup.log
#      echo " "
#      echo "`date` :-> Iniciando Agent ..."
#      su - $ORA_OWNER -c ". /home/oracle/agent12c.env; emctl start agent"
#      echo " "
#   else
#      echo "Erro na inicializacao do CRS. Db nao pode ser iniciado."
#   fi

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
   su - $ORA_OWNER -c ". /home/oracle/agent12c.env; emctl stop agent"
   echo " "
   echo "`date` :-> Parando listeners ( $LIS_LISTENERS )"
#################################################
#       Startup oracle 11g, adicionado por:
#       Hermes Pimentel
#       16/04/2013
#################################################

   echo " "
   echo "`date` :-> Fechando banco Oracle. Pode levar alguns minutos ..."

#   su - $ORA_OWNER -c $ORACLE_HOME/bin/dbshut $ORACLE_HOME
#   tail -12 $ORACLE_HOME/shutdown.log
#   echo " "

        DB_STATUS=`$ORA_CRS_HOME/bin/srvctl status instance -d $DB_NAME -i $INST_NAME` > /dev/null 2>&1
        echo $DB_STATUS | grep "is running on node" > /dev/null 2>&1
                if [ $? = 0 ] ; then
                                echo " "
                                echo "Baixando Instance..:" $INST_NAME
                                $ORA_CRS_HOME/bin/srvctl stop instance -d $DB_NAME -i $INST_NAME -o immediate
                                sleep 5
                                DB_STATUS=`$ORA_CRS_HOME/bin/srvctl status instance -d $DB_NAME -i $INST_NAME` > /dev/null 2>&1
                                echo $DB_STATUS | grep "is not running on node" > /dev/null 2>&1

                                if [ $? = 0 ] ; then
                                        echo " "
                                        echo "Shutdown immediate OK"
                                        echo $DB_STATUS
                                        echo " "
                                        echo " "
                                else

                                        $ORA_CRS_HOME/bin/srvctl stop instance -d $DB_NAME -i $INST_NAME -o immediate
                                        DB_STATUS=`$ORA_CRS_HOME/bin/srvctl status instance -d $DB_NAME -i $INST_NAME` > /dev/null 2>&1
                                        echo " "
                                        echo "Shutdown status: " $DB_STATUS
                                        echo " "
                                        echo " "

                                fi

                else
                                DB_STATUS=`$ORA_CRS_HOME/bin/srvctl status instance -d $DB_NAME -i $INST_NAME` > /dev/null 2>&1
                                "Database jÃ¡ esta DOWN " $DB_STATUS

                fi

   echo "`date` :-> Finalizando Clusterware"
   $ORA_CRS_HOME/bin/crsctl stop crs
   echo " "

   rm /var/lock/subsys/racdb
   } > $LOG 2>&1
   cat $LOG
   exit 0
fi

if [ "$1" = "status" ] ; then

###########################################
# Adptando script para o Oracle 11g
# Alterado por Hermes Pimentel 16/04/2013
###########################################

   RET_GERAL=0

   # Verifica o status do cluster (CRS)
   echo " "
   echo "Verificando status do cluter CRS..."
   CRS_STATUS=`$ORA_CRS_HOME/bin/crsctl status resource -t ` > /dev/null 2>&1
   $ORA_CRS_HOME/bin/crsctl status resource -t > /dev/null 2>&1
   if [ ! $? = 0 ] ; then
      echo "Cluster CRS nao ativo"
      echo " "
      RET_GERAL=1
   else
          echo " "
          echo "STATUS CRS:"
          $ORA_CRS_HOME/bin/crsctl status resource -t
          echo " "
          echo " "
      echo "Cluster CRS ativo nessa maquina."
      echo " "
          echo " "
                   echo "Verificando status da Instance Oracle..."
                   echo " "
               echo " "

                        DB_STATUS=`$ORA_CRS_HOME/bin/srvctl status instance -d $DB_NAME -i $INST_NAME` > /dev/null 2>&1
                        echo $DB_STATUS | grep "is running on node" > /dev/null 2>&1
                                if [ $? = 0 ] ; then
                                                echo " "
                                                echo "Instance Oracle ativa nessa maquina."
                                                echo " "
                                                echo $DB_STATUS
                                                echo " "

                                else
                                        echo " "
                                        echo "Instance Oracle nao ativa."
                                    echo " "
                                        echo $DB_STATUS

                                fi

                           echo "Verificando Listeners :"
                                        $ORA_CRS_HOME/bin/srvctl status listener
                                                echo " "
                                        $ORA_CRS_HOME/bin/srvctl status scan_listener
                                                echo " "
                           echo "Verificando Scan  :"
                                        $ORA_CRS_HOME/bin/srvctl status scan_listener

   fi

  echo "Verificando agent..."
   su - $ORA_OWNER -c ". /home/oracle/agent12c.env; emctl status agent"
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

