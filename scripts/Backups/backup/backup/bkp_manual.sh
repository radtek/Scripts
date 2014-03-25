DIR_BASE=$ORACLE_BASE/oracledba/backup
DIR_LOGS=$ORACLE_BASE/oracledba/logs

if [ ! $# = 1 ] ; then
  echo " "
  echo "Script que realiza backup online do banco oracle."
  echo "Deve receber como parametro o nome da instance (ORACLE_SID) ou"
  echo "a string \"ENV\" indicando que deve pegar da variavel de ambiente:\$ORACLE_SID."
  echo " "
  echo "Sua variavel de ambiente ORACLE_SID esta atualmente setada para: $ORACLE_SID"
  echo " "
  echo "Exemplos:"
  echo "$0 oradb1 (para realizar shutdown da instance oradb1)"
  echo "ou"
  echo "$0 ENV (para realizar shutdown da instance setada em \$ORACLE_SID)"
  echo " "
  exit 1
fi

SIDPAR=$1
if [ ! "$SIDPAR" = "ENV" ] ; then
   ORACLE_SID=$SIDPAR
   export ORACLE_SID
fi

# Verifica se o arquivo de configuracao passado existe.
if [ ! -f $DIR_BASE/bkp_${ORACLE_SID}.conf ]; then
   echo
   echo "Arquivo de configuracao $DIR_BASE/bkp_${ORACLE_SID}.conf nao encontrado."
   echo "Certifique-se que o arquivo existe."
   echo
   exit 1
fi

. $DIR_BASE/bkp_${ORACLE_SID}.conf

echo "Realizando backup do banco:$ORACLE_SID ..."


$DIR_BASE/hotbkp_oracle.sh $DIR_BASE/bkp_${ORACLE_SID}.conf FULL $CLASS_BD_DEF $SCHED_BD_DEF

RET=$?

if [ $RET = 0 ] ; then
  echo "Backup realizado com sucesso."
else
  echo "ERRO no backup. Consultar logs em:$DIR_LOGS."
fi

exit $RET


