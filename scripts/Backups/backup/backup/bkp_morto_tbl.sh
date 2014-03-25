#
# Script que realiza bkp morto das tablespaces.
# Utiliza a schedule SCHED_MORTO_DEF que deve estar setada no arquivo de configuracao.
#

# Deve ser passado 2 parametros.
if [ ! $# = 2 ] ; then
   echo
   echo "Realiza backup de tablespace(s)."
   echo "Deve ser passado 2 parametros:"
   echo "1) Arquivo com as variaveis de configuracao;"
   echo "2) Lista de tablespaces (entre aspas e separadas por espaço) "
   echo "$0 <caminho/nome_arq_configuracao> \"TBL1 TBL2\" "
   echo " "
   exit 1
fi

CONF=$1
LISTTBL=$2

# Verifica se o arquivo de configuracao passado existe.
if [ ! -f $CONF ]; then
   echo
   echo "Arquivo $CONF nao encontrado."
   echo "Certifique-se que o arquivo existe e/ou passe o caminho completo."
   echo
   exit 2
fi

# Inicializa as variaveis de ambiente que estao no arquivo de configuracao
. $CONF

# Verifica se a classe de morto esta setada
if [ -z "$CLASS_MORTO_DEF" ] ; then
   echo
   echo "A variavel de ambiente CLASS_MORTO_DEF deve ser setada para realizacao de morto."
   echo
   exit 3
fi

# Verifica se a schedule de morto esta setada
if [ -z "$SCHED_MORTO_DEF" ] ; then
   echo
   echo "A variavel de ambiente SCHED_MORTO_DEF deve ser setada para a schedule com a retencao de morto."
   echo
   exit 3
fi

# Seta o diretorio de backup tambem no path
PATH=$PATH:$BASE_BKP

# Inicializa as funções genericas de backup.
if [ ! -f ${BASE_BKP}/functions.bkp ]; then
   echo
   echo "Arquivo ${BASE_BKP}/functions.bkp com as funcoes genericas nao encontrado."
   echo
   exit 4
else
   . ${BASE_BKP}/functions.bkp
fi

# Inicia o loop de bkp das tablespaces
RET_PROCESSO=0
for T in $LISTTBL
do
  echo "Iniciando backup da tablespace $T ..."
  # Monta o nome do arquivo de log
  RMAN_LOG_TB=$DIR_LOGS/rman_tb_${T}.log.`date +'%d%m%Y%H%M%S'`

  #Inicia o conjunto de comandos que terao sua saida direcionada para um arquivo que sera enviado por email
  echo "Gera comando para o rman ..."
  echo "Gera_cmd_tbl_rman $CLASS_MORTO_DEF $SCHED_MORTO_DEF $T"
  Gera_cmd_tbl_rman $CLASS_MORTO_DEF $SCHED_MORTO_DEF $T

  echo "Executa o rman para realizar o bkp:"

  $ORACLE_HOME/bin/rman target $BKPUSER/$BKPPASS catalog $CONEXAO_RMAN cmdfile $ARQ_CMD_RMAN_TB msglog $RMAN_LOG_TB

  RET_RMAN_AR=$?

  if [ $RET_RMAN_AR = 0 ] ; then
     echo " "
     echo "Final do bkp da tablespace $T com SUCESSO:`date +'%d/%m/%Y %H:%M:%S'`"
     echo " "
  else
     echo " "
     echo "Final do bkp da tablespace $T com ERRO:`date +'%d/%m/%Y %H:%M:%S'`"
     echo "Retorno:$RET_RMAN_AR"
     echo " "
     RET_PROCESSO=1
  fi
  echo "Verificar detalhes no arquivo de log:$RMAN_LOG_TB"
  echo " "
done

echo "Final do processo."
exit ${RET_PROCESSO}
