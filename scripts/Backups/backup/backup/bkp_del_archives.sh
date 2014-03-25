##################################################################
# Realiza backup dos archives pelo rman e exclui se foi com      #
# sucesso.                                                       #
# Gediel Luchetta (out/2004).                                    #
##################################################################

# Deve ser passado um arquivo de configuracao como parametro.
if [ ! $# = 1 ] ; then
   echo
   echo "Deve ser passado 1 parametro:"
   echo "1) Arquivo com as variaveis de configuracao;"
   echo "$0 <caminho/nome_arq_configuracao> "
   echo " "
   exit 1
fi

CONF=$1


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

# Seta o diretorio de backup tambem no path
PATH=$PATH:$BASE_BKP

# Seta o prefixo do arquivo de lock que evita dois bkps simultaneos.
ARQ_LOCK=$BASE_BKP/lock_bkp_arc_${ORACLE_SID}.pid

# Inicializa as funcoes genericas de backup.
if [ ! -f ${BASE_BKP}/functions.bkp ]; then
   echo
   echo "Arquivo ${BASE_BKP}/functions.bkp com as funcoes genericas nao encontrado."
   echo
   exit 3
else
   . ${BASE_BKP}/functions.bkp
fi

# Pega a Data e hora de inicio.
DATA=`date +'%d/%m/%Y'`
HORA=`date +'%H:%M:%S'`

# Testa pra ver se ja tem um bkp de archives ocorrendo nesse momento.
if [ -f $ARQ_LOCK ]; then
   PIDBKP=`cat $ARQ_LOCK`
   echo "Verifica se existe um processo com o pid do backup:${PIDBKP}" 
   ps -ef | grep ${PIDBKP} | grep -v grep 
   if [ $? = 0 ] ; then
      echo " "
      echo "Encontrado arquivo de lock do bkp:$ARQ_LOCK e processo rodando..."
      echo "Obs: O conteudo do arquivo de lock eh o PID do processo de bkp."
      echo " "
      exit 4
   else
      echo " "
      echo "Encontrado arquivo de lock do bkp:$ARQ_LOCK mas processo nao esta rodando."
      echo "Gerando um novo arquivo de lock e disparando o backup..."
      echo " "
   fi

fi

# Gera um arquivo de lock contendo o PID do processo atual.
echo $$ > $ARQ_LOCK

#
# Verifica se o repositorio do rman esta ok, caso necessite se conectar.
# Se tiver qualquer problema de conexao com o catalog do rman, realiza backup sem catalago.
#
if [ ! -z "$CONEXAO_RMAN" ] ; then
    Testa_conexao "$CONEXAO_RMAN" 2 $ORACLE_SID
    if [ ! $? = 0 ] ; then # conexao falhou
       CONEXAO_RMAN=
    fi
fi


# Monta o nome do arquivo de log
ARQ_LOG=$ARQ_LOG.ARC.`date +'%d%m%Y%H%M%S'`
RMAN_LOG_AR=$DIR_LOGS/rman_ar.log.`date +'%d%m%Y%H%M%S'`
SUBJECT="Subject: Backup ARC Maq:`hostname`  SID:$ORACLE_SID"

#Inicia o conjunto de comandos que terao sua saida direcionada para um arquivo que sera enviado por email
{

# Monta um cabecalho pro email.
echo $SUBJECT
echo "To: $LISTA_EMAILS"

echo
echo "Inicio: $DATA $HORA"
echo "--------------------------------------------------------------------------------"
echo " "
echo "Backup dos archives com o rman ..."
echo "Gera comando para o rman ..."
if [ ! -z "$CONEXAO_RMAN" ] ; then
  Gera_cmd_arc_rman $CLASS_AR_DEF $SCHED_AR_DEF Y $ULTSEQ
else
  Gera_cmd_arc_rman $CLASS_AR_DEF $SCHED_AR_DEF N $ULTSEQ
fi

################################################################
#### Nesse ponto o script foi personalizado para a basedb
#### Antes de fazer a copia e remover os archives chama o
#### rsync para mandar os archives para outra maquina.
#### Gediel, 05/09/2003
################################################################
if [ "`hostname`" = "cedral.terra.com.br" ] ; then
   DESTINO="imbe"
else
   if [ "`hostname`" = "imbe.terra.com.br" ] ; then
      DESTINO="cedral"
   else
      DESTINO=""
   fi
fi

if [ ! -z "$DESTINO" ] ; then
  /usr/bin/rsync -av --size-only /o03/oradata/oradb1/archive/ORA* ${DESTINO}.terra.com.br::archives_backup/ >>/Backup_Archives/rsync.log 2>&1
fi

echo
echo "Executa o rman para realizar dos archives:"
} >$ARQ_LOG 2>&1
if [ ! -z "$CONEXAO_RMAN" ] ; then
  $ORACLE_HOME/bin/rman target / catalog $CONEXAO_RMAN cmdfile $ARQ_CMD_RMAN_AR msglog $RMAN_LOG_AR
else
  $ORACLE_HOME/bin/rman target / nocatalog cmdfile $ARQ_CMD_RMAN_AR msglog $RMAN_LOG_AR
fi

RET_RMAN_AR=$?

if [ $RET_RMAN_AR = 0 ] ; then
  {
   echo " "
   echo "Final do rman (ARC) com SUCESSO:`date +'%d/%m/%Y %H:%M:%S'`"
   echo " "
  } >>$ARQ_LOG
else
  {
   echo " "
   echo "Final do rman (ARC) com ERRO:`date +'%d/%m/%Y %H:%M:%S'`"
   echo "Retorno:$RET_RMAN_AR"
   echo "ERRO: "
   echo "-------------------------------------------------"
  } >>$ARQ_LOG
  cat $RMAN_LOG_AR >>$ARQ_LOG
  echo "-------------------------------------------------" >>$ARQ_LOG
fi

# Pega a Data e hora de termino.
DATA=`date +'%d/%m/%Y'`
HORA=`date +'%H:%M:%S'`

{

echo
echo "--------------------------------------------------------------------------------"
echo "Termino: $DATA $HORA"

# Finaliza o conjunto de comandos
} >>$ARQ_LOG 2>&1


if [ $RET_RMAN_AR = 0 ] ; then
  echo "Backup dos archives realizado com sucesso."
else
  echo "ERRO na realizacao do backup (cod ret = $RET_RMAN_AR). Detalhes no arquivo $RMAN_LOG_AR"
  #
  # Manda email notificando, somente em caso de erro.
  #
  Send_mail "$SUBJECT" "$LISTA_EMAILS" $ARQ_LOG

fi

# Remove o arquivo de lock.
rm $ARQ_LOCK

exit $RET_RMAN_AR
