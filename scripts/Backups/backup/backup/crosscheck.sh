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
   echo "Exemplos:"
   echo "$0 <caminho/nome_arq_configuracao> "
   echo
   exit 1
fi

CONF=$1
INICIO=`date +'%d%m%Y%H%M%S'`



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

# chama rman p/ fazer o crosscheck com o software que gerencia o bkp nas fitas

rman target / catalog $CONEXAO_RMAN msglog=$DIR_LOGS/crosscheck.log.$INICIO<<eof
allocate channel for maintenance type 'sbt_tape';
crosscheck backup of database;
exit;
eof


# Pega data hora do final.
FINAL=`date +'%d/%m/%Y %H:%M:%S'`


{
echo " " 
echo " "
echo "Final do script:$FINAL" 
} >> $DIR_LOGS/crosscheck.log.$INICIO

