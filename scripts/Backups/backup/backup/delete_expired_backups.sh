#
# Autor....:Junior - Advanced - 21-05-2003
#
# Descricao: Este escript roda um crosscheck dos backups
#            com retencao inferior a 7 dias e deleta
#            os backups expirados a mais de 90 dias
#
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
. $HOME/.bash_profile


# Seta o diretorio de backup tambem no path
PATH=$PATH:$BASE_BKP

$ORACLE_HOME/bin/rman target / catalog $CONEXAO_RMAN msglog $DIR_LOGS/delete_expired_backups.log <<EOF
allocate channel for maintenance type 'sbt';
crosscheck backup completed before 'sysdate-7';
delete noprompt expired backup completed before 'sysdate-90';
exit;
# Final dos comandos do rman.
EOF

# Guarda o retorno do rman (0 = sucesso , <> 0 = erro)
RET_RMAN=$?
echo "Retorno:$RET_RMAN"

