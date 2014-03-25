#################################################################
# Realiza backup do banco oracle com o RMAN para tape ou disk.  #
# Gediel Luchetta (fev/2002).                                   #
#################################################################

# Chama script que verifica o parametro de entrada e o ambiente.

# Deve ser passado um arquivo de configuracao como parametro.
if [ ! $# -eq 1 ] ; then
   echo
   echo "Deve ser passado 1 parametro:"
   echo "1º) Um arquivo de configuracao com as variáveis de ambientes"
   echo "Exemplo:"
   echo "$0 /o01/app/oracle/oracledba/backup/bkp_oradb1.conf"
   echo
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


# Arquivo temporario para o email.
ARQ_MAIL=/tmp/bkp_$ORACLE_SID.mail

# Seta o prefixo do arquivo de lock que evita dois bkps simultaneos.
ARQ_LOCK=$BASE_BKP/lock_bkp_bd_disk_${ORACLE_SID}.pid

# Testa pra ver se ja tem um bkp de archives ocorrendo nesse momento.
if [ -f $ARQ_LOCK ]; then
  echo " "
  echo "Encontrado arquivo de lock do bkp:" $ARQ_LOCK
  echo "Verifique se ja existe um bkp em andamento."
  echo "Obs: O conteudo do arquivo de lock eh o PID do processo de bkp."
  echo " "
  exit 5
else
  # Gera um arquivo de lock contendo o PID do processo atual.
  echo $$ > $ARQ_LOCK
fi



# Inicializa as funções genericas de backup.
if [ ! -f ${BASE_BKP}/functions.bkp ]; then
   echo
   echo "Arquivo ${BASE_BKP}/functions.bkp com as funcoes genericas nao encontrado."
   echo
   exit 4
else
   . ${BASE_BKP}/functions.bkp
fi

#
# Verifica se o repositorio do rman esta ok, caso necessite se conectar.
# Se tiver qualquer problema de conexao com o catalog do rman, realiza backup sem catalago.
#
if [ ! -z "$CONEXAO_RMAN" ] ; then
    Testa_conexao "$CONEXAO_RMAN" 2
    if [ ! $? = 0 ] ; then # conexao falhou
       CONEXAO_RMAN=
    fi
fi

# Pega a Data e hora de inicio.
INICIO=`date +'%d/%m/%Y %H:%M:%S'`

# Monta o nome do arquivo de log
ARQ_LOG=${ARQ_LOG}_DISK.`date +'%d%m%Y%H%M%S'`

# Cria o arquivo com os comandos do rman
##############################################################################################
{
echo "resync catalog;"
echo "run"
echo "{"
echo "sql 'alter system archive log current';"
echo "allocate channel c1 type disk;"
} > $BASE_BKP/cmd_rman_disk.rcv

sqlplus '/ as sysdba' <<eof
set feed off;
set head off;
set echo off;
set term off;
set pages 200;
set lines 80;
spool /tmp/cmd_bkp_dtf.log
select 'backup datafile '||file_id||' format ''$DIR_DEST_BD_BKP_01/bkp_datafile_'||file_id||'.rman'';'
from dba_data_files
where mod(to_number(substr(file_name,3,2)),2) = 0
union all
select 'backup datafile '||file_id||' format ''$DIR_DEST_BD_BKP_02/bkp_datafile_'||file_id||'.rman'';'
from dba_data_files
where mod(to_number(substr(file_name,3,2)),2) <> 0
/
spool off;
exit;
eof

cat /tmp/cmd_bkp_dtf.log | grep backup | grep -v select >> $BASE_BKP/cmd_rman_disk.rcv

{
echo "sql 'alter system archive log current';"
echo "sql 'alter database backup controlfile to trace';"
echo "}"
echo "resync catalog;"
echo "exit;"
} >> ${BASE_BKP}/cmd_rman_disk.rcv
##############################################################################################


#Inicia o conjunto de comandos que terao sua saida direcionada para um arquivo que sera enviado por email
{

echo
echo "Inicio: $INICIO"
echo "--------------------------------------------------------------------------------"

echo "Apaga os bkps em disco do dia anterior..."
echo "rm -f $DIR_DEST_BD_BKP_01/bkp_FULL*.rman"
echo "rm -f $DIR_DEST_BD_BKP_02/bkp_FULL*.rman"
rm -f $DIR_DEST_BD_BKP_01/bkp_*.rman
rm -f $DIR_DEST_BD_BKP_02/bkp_*.rman

echo
echo "Executa o rman para realizar o backup do banco:"
if [ ! -z "$CONEXAO_RMAN" ] ; then
   CMD="rman target / catalog $CONEXAO_RMAN"
else
   CMD="rman target / nocatalog"
fi

$CMD cmdfile=${BASE_BKP}/cmd_rman_disk.rcv 
RET_RMAN=$?

echo " "
echo " "

echo "Sincroniza o catalog do rman..."

if [ ! -z "$CONEXAO_RMAN" ] ; then
$CMD <<eof
allocate channel for maintenance type disk;
crosscheck backup ;
delete noprompt expired backup completed before 'sysdate-3';
exit;
# Final dos comandos do rman.
eof
fi


echo " "
echo " "

echo "Bkp_control $BKPUSER $BKPPASS $DIR_DEST_CTL"
Bkp_control $BKPUSER $BKPPASS $DIR_DEST_CTL

# Pega a Data e hora de termino.
DATA=`date +'%d/%m/%Y'`
HORA=`date +'%H:%M:%S'`

echo
echo "--------------------------------------------------------------------------------"
echo "Termino: $DATA $HORA"



} >$ARQ_LOG 2>&1

# Monta um cabecalho pro email. Se deu erro envia o log junto.

SUBJECT="Subject: BACKUP PRA DISCO (Maq:`hostname`  SID:$ORACLE_SID)"

# Pega data hora do final.
FINAL=`date +'%d/%m/%Y %H:%M:%S'`

{
  echo $SUBJECT
  echo "To: $LISTA_EMAILS"
  echo " "
  echo "############################################################"
  echo "Inicio.............:$INICIO"
  echo "Final..............:$FINAL"
  echo "############################################################"
  echo " "
} > $ARQ_MAIL

cat $ARQ_LOG >> $ARQ_MAIL

if [ ! $RET_RMAN = 0 ] ; then
  #
  # Manda email notificando em caso de erro no rman
  #
  Send_mail "$SUBJECT" "$LISTA_EMAILS" $ARQ_MAIL
fi


# Remove o arquivo de lock.
rm $ARQ_LOCK
