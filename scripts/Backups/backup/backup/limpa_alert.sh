#!/bin/sh
###############################################################################################################
#Esse script foi criado para tirar as mensagens ORA-01157, ORA-01110 e ORA-27037 do alert dos bancos
#que possuem tablespaces Offline/Read only e que tem backup com o rman. A cada backup do rman esses erros
#apareciam para os datafiles offline mesmo tempo a opcao "Skip offline" no script do rman.
#Gediel Luchetta, abril 2004.
###############################################################################################################

ALERT=$DBA/bdump/alert_$ORACLE_SID.log

grep "ORA-01157" $ALERT > /dev/null
if [ $? = 0 ] ; then
  {
   sed 's/ORA-01157/TRR-01157/' $ALERT | sed 's/ORA-01110/TRR-01110/' | sed 's/ORA-27037/TRR-27037/'
   echo "[ORACLEDBA]: Rodou script de correcao do alert -> `date`"
  } > $ALERT.tmp
  cat  $ALERT.tmp > $ALERT
fi

