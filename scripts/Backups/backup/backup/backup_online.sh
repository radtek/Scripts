# Executa backup online Oracle - BASEDB 

# DIRETORIO DE LOGS
DIR_LOG=/o01/app/oracle/oracledba/logs

# DIRETORIOS DE BACKUP EM DISCO
DIR_BKP="/o03/oradata/oradb1/bkp"

# Arquivo temporario de log (email)
LOG_TMP=/tmp/bkponline_oradb1.log

# Lista de emails
LISTAMAIL="gedielrs@hotmail.com, junior_amaral_poa@yahoo.com.br"

HOJE=`date +'%d/%m/%Y'`
HORA=`date +'%H:%M:%S'`

echo "Subject: Backup online oradb1(basedb) $HOJE $HORA" > $LOG_TMP
echo >> $LOG_TMP

##  Testa se o banco esta no ar.

STR=`ps -ef | grep -v grep | grep "ora_pmon"`

if [ -z $STR ] 
 then 
  echo "Banco fora. Backup online nao rodou." >> $LOG_TMP
  echo "--------------------------------------------------" >> $LOG_TMP 
  exit 0

else

  rm /o01/app/oracle/oracledba/backup/bkp_basedb.sql

  sqlplus -s /nolog @/o01/app/oracle/oracledba/backup/gbkp_basedb.sql

  sqlplus -s /nolog @/o01/app/oracle/oracledba/backup/bkp_basedb.sql

  #/o01/app/oracle/backup/limpa_arc.sh

  #/o01/app/oracle/backup/limpa_trc.sh

  # Manda spool do sqlplus por email.
  echo "Log spool do oracle:" >> $LOG_TMP
  cat $DIR_LOG/bkp_basedb.log >> $LOG_TMP
  echo "--------------------------------------------------" >> $LOG_TMP

  # Manda um ls dos diretorios do backup por email
  echo "Log ls dos diretorios de backup em disco:" >> $LOG_TMP
  for D in $DIR_BKP
  do
    echo "Diretorio:$D" >> $LOG_TMP 
    ls -lt $D >> $LOG_TMP
  done
  echo "--------------------------------------------------" >> $LOG_TMP 

  # Manda um df por email
  echo "Log DF do sistema de arquivos:" >> $LOG_TMP
  df -k >> $LOG_TMP
  echo "--------------------------------------------------" >> $LOG_TMP 

fi

HOJE=`date +'%d/%m/%Y'`
HORA=`date +'%H:%M:%S'`

echo "Final backup online oradb1 (basedb):$HOJE $HORA" >> $LOG_TMP

# Manda email confirmando a operacao
mail -tw $LISTAMAIL < $LOG_TMP
