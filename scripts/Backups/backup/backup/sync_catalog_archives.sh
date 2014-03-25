#################################################################
# Realiza uma verificagco entre o catalago do netbackup e       #
# do rman para sincroniza-los com relagco as informagues        #
# de quais archives foram e ainda estco no backup.              #
# Gediel Luchetta (jan/2002).                                   #
#################################################################

# Deve ser passado um arquivo de configuracao como parametro.
if [ ! $# -eq 1 ] ; then
   echo
   echo "Um arquivo de configuracao deve ser passado como parametro."
   echo "$0 <caminho/nome_arq_configuracao>"
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
. $HOME/.profile
. $HOME/.bash_profile

# Seta o diretorio de backup tambem no path
PATH=$PATH:$BASE_BKP

# Inicializa as fungues genericas de backup.
if [ ! -f ${BASE_BKP}/functions.bkp ]; then
   echo
   echo "Arquivo ${BASE_BKP}/functions.bkp com as funcoes genericas nao encontrado."
   echo
   exit 3
else
   . ${BASE_BKP}/functions.bkp
fi

$ORACLE_HOME/bin/rman target $BKPUSER/$BKPPASS catalog $CONEXAO_RMAN <<EOF
Change Archivelog All Crosscheck;
Change Archivelog All validate;
exit;
# Final dos comandos do rman.
EOF

# Guarda o retorno do rman (0 = sucesso , <> 0 = erro)
RET_RMAN=$?
echo "Retorno:$RET_RMAN"

