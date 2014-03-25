
Todas pendências ok!
	-> Aberto ticket SUPINFRA - ticket 8645 - ok!
		-> Instalar netbackup - ok!
		-> repassar os parametros que devem ser utilizados no netbackup - ok!
	-> Ajustar o script "export_schemas_v7.sh" para enviar para fita - ok!
	-> Validar um backup e restore - ok!



Pendências:
	-> Aberto ticket SUPINFRA - ticket 8645
		-> Instalar netbackup
		-> repassar os parametros que devem ser utilizados no netbackup
	-> Ajustar o script "export_schemas_v7.sh" para enviar para fita
	
Documentação:		
		-> Dados do script: 
			-> Servidor - 1kk.tpn.terra.com		
			-> Banco de dados  - orahlg02
			-> Local script - /usr/local/oracle/oracledba/scripts/export_schemas_v7.sh
			-> Contexto -> Usuário oracle
		-> Script basicamente faz o seguinte:
			-> Reinicializa o ambiente, removendo dados execuções anteriores com erro
			-> Criar um novo diretório no oracle conforme data atual para export via datapump		
			-> Realiza o export via datapump conforme vetor de usuários
			-> Comprime os dumps 
			-> Envia para fita (falta implementar)
			-> Faz o controle de retenção dos logs e dos dumps em disco
		-> Script agendado na crontab do oracle para executar todo dia 02:00 (00:00 BRT):
			[oracle@1kk oracledba]$ crontab -l
			0 02 * * * /usr/local/oracle/oracledba/scripts/export_schemas_v7.sh
		-> Diretório utilizado para gerar o dump tem o seguinte formato /usr/local/oracle/oracledba/dmp/EXPORT_V7_ + <DATA>
		-> Diretório criado no oracle tem nome fixo "EXPORT_V7", além disso é recriado a cada nova execução
		-> Dumps são gerados com o seguinte padrão de nome DMP_ + <DATA> + <NOME_OWNER>
			-> Retenção 7 dias
		-> Logs de execução do script são gerados em /usr/local/oracle/oracledba/logs e tem o seguinte formato exp_v7_ + <DATA>
			-> Retenção 30 dias
		-> Para adicionar novos usuários no export basta adicionar mais 1 item ao vertor OWNERS
			OWNERS[6]=VCMMGMT
			OWNERS[7]=VCMCONT
	

###########################################################################################
# Script tem como objetivo exportar os usuÃ¡os do V7 para dump externo e enviar para fita
# Novas owners:
#       -> Adicionar ao vetor OWNERS na ultima posicao o nome da tabela qualificando com o owner, ex:
#               Nova owner:
#                       teste4
#               Codigo atual:
#                       OWNERS[7]=VCMCONT
#                       OWNERS[8]=VCMSYS
#               Alterar para:
#                       OWNERS[7]=VCMCONT
#                       OWNERS[8]=VCMSYS
#                       OWNERS[9]=VCMNOVO
#
# crontab:
#       0 02 * * * /usr/local/oracle/oracledba/scripts/export_schemas_v7.sh
#
#
###########################################################################################


#### BASH PROFILE VARIABLES
PATH=$PATH:$HOME/bin

export PATH

#########################################################
ORACLE_BASE=/usr/local/oracle
ORACLE_HOME=$ORACLE_BASE/product/10.2.0
ORACLE_TERM=xterm
ORACLE_SID=orahlg02
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
NLS_DATE_FORMAT=DD/MM/YYYY
ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/local/lib
PATH=$PATH:$ORACLE_HOME/bin:/sbin:/usr/sbin:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/root/bin:$ORACLE_BASE/OPatch
OH=$ORACLE_HOME
ADM=$ORACLE_BASE/oracledba
DBA=$ORACLE_BASE/admin/$ORACLE_SID
# ATENCAO: manter os exports separados das definicoes
export ORACLE_BASE ORACLE_HOME ORACLE_SID ORACLE_TERM
export NLS_LANG NLS_DATE_FORMAT ORA_NLS33
export LD_LIBRARY_PATH PATH
export OH ADM DBA



# Lista dinamica de owners do V7 para export
OWNERS[1]=VCMSYS
OWNERS[2]=FEED_SYSTEM
OWNERS[3]=VCMCONTENT
OWNERS[4]=VCMLIVE
OWNERS[5]=VCMLIVE_B
OWNERS[6]=VCMMGMT
OWNERS[7]=VCMCONT

TAMANHO=${#OWNERS[@]}

#logs do script
DIR_LOG=/usr/local/oracle/oracledba/logs
LOG=${DIR_LOG}/exp_v7_`date +'%Y-%m-%d'`.log

#informacoes do dump
DMP_DIRDEST_BASE=/usr/local/oracle/oracledba/dmp
DMP_DIRDEST_NAME=EXPORT_V7_`date '+%m%d%y%H%M'`
DMP_DIRDEST=/usr/local/oracle/oracledba/dmp/$DMP_DIRDEST_NAME
DMP_DIRNAME=EXPORT_V7
DMP_BASENAME=DMP_`date '+%m%d%y%H%M'`

# carrega variaveis de ambiente ORACLE
export ORACLE_BASE=/usr/local/oracle;
export ORACLE_HOME=/usr/local/oracle/product/10.2.0;
export ORACLE_SID=orahlg02;
export ORACLE_TERM=xterm;
ORACLE_SID=orahlg02
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
NLS_DATE_FORMAT=DD/MM/YYYY
ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/local/lib
PATH=$PATH:$ORACLE_HOME/bin:/sbin:/usr/sbin:/usr/bin/X11:/usr/local/bin:/usr/local/sbin:/root/bin:$ORACLE_BASE/OPatch
OH=$ORACLE_HOME
ADM=$ORACLE_BASE/oracledba
DBA=$ORACLE_BASE/admin/$ORACLE_SID
# ATENCAO: manter os exports separados das definicoes
export ORACLE_BASE ORACLE_HOME ORACLE_SID ORACLE_TERM
export NLS_LANG NLS_DATE_FORMAT ORA_NLS33
export LD_LIBRARY_PATH PATH
export OH ADM DBA



# Lista dinamica de owners do V7 para export
OWNERS[1]=VCMSYS
OWNERS[2]=FEED_SYSTEM
OWNERS[3]=VCMCONTENT
OWNERS[4]=VCMLIVE
OWNERS[5]=VCMLIVE_B
OWNERS[6]=VCMMGMT
OWNERS[7]=VCMCONT

TAMANHO=${#OWNERS[@]}

#logs do script
DIR_LOG=/usr/local/oracle/oracledba/logs
LOG=${DIR_LOG}/exp_v7_`date +'%Y-%m-%d'`.log

#informacoes do dump
DMP_DIRDEST_BASE=/usr/local/oracle/oracledba/dmp
DMP_DIRDEST_NAME=EXPORT_V7_`date '+%m%d%y%H%M'`
DMP_DIRDEST=/usr/local/oracle/oracledba/dmp/$DMP_DIRDEST_NAME
DMP_DIRNAME=EXPORT_V7
DMP_BASENAME=DMP_`date '+%m%d%y%H%M'`

# carrega variaveis de ambiente ORACLE
export ORACLE_BASE=/usr/local/oracle;
export ORACLE_HOME=/usr/local/oracle/product/10.2.0;
export ORACLE_SID=orahlg02;
export ORACLE_TERM=xterm;

{

reset_ambiente()
{
        echo
        echo "########## INICIO RESET AMBIENTE ######################"

        echo '-> Remover diretÃ³ destino do dump'
        echo $DMP_DIRDEST
        rm -rf $DMP_DIRDEST

        echo '-> Criar diretÃ³ destino do dump'
        mkdir -p $DMP_DIRDEST

        echo '-> Faz o drop e recria o diretorio no oracle'
        sqlplus / as sysdba <<EOF
set lines 2000
set pages 1000
set echo on
DROP DIRECTORY $DMP_DIRNAME;
CREATE DIRECTORY $DMP_DIRNAME AS '$DMP_DIRDEST';

col owner for a20
col directory_name for a20
col directory_path for a100
select owner, directory_name, directory_path from dba_directories where directory_name = '$DMP_DIRNAME';
quit;
EOF

        echo "########## FIM RESET AMBIENTE ######################"
}

export_schemas()
{
        echo
        echo "########## INICIO EXPORT SCHEMA ######################"

        DUMP_FULLNAME=""

        for ((i=1; i<TAMANHO; i++))
        do

                echo `echo "----> Exportando owner ${OWNERS[$i]}"`
                echo "-> Inicio `date +'%Y-%m-%d %k:%M:%S'`"

                OWNER=${OWNERS[$i]}
                DUMP_NAME=$DMP_BASENAME"_"$OWNER.dmp
                LOG_NAME=$DMP_BASENAME"_"$OWNER.log
                DUMP_FULLNAME=$DMP_DIRDEST"/"$DUMP_NAME

                echo "-> variaveis"
                echo $OWNER
                echo $DUMP_NAME
                echo $LOG_NAME
                echo $DUMP_FULLNAME

                echo "-> export datapump"
                expdp userid=\'/ as sysdba\' directory=$DMP_DIRNAME  dumpfile=$DUMP_NAME logfile=$LOG_NAME schemas=$OWNER FLASHBACK_TIME=\"to_timestamp\(to_char\(systimestamp, \'DD-MON-RR HH.MI.SSXFF AM\'\), \'DD-MON-RR HH.MI.SSXFF AM\'\)\"

                echo "-> compress"
                cd $DMP_DIRDEST
                gzip $DUMP_NAME
                cd -
                echo "-> Final `date +'%Y-%m-%d %k:%M:%S'`"
        done

        echo "########## FINAL EXPORT SCHEMA ######################"
}


envia_fita()
{
        echo "########## INICIO ENVIA FITA ######################"


        NETBACKUP_CLIENT="/usr/openv/netbackup/bin/bparchive"
        NETBACKUP_POLICY="ORACLE-hlg-db"
        NETBACKUP_SCHED="archive"
        NETBACKUP_SERVER="brasilia.bkp.terra.com"
        NETBACKUP_TYPE=0

        ### diretorio de copia
        PARAM_DIR=$DMP_DIRDEST

        ### descricao para identificar arquivo
        PARAM_DES=$DMP_DIRDEST_NAME

        DTATUAL=`date +'%Y%m%d_%H%M%S'`
        NETBACKUP_LOG=/usr/local/oracle/oracledba/logs/BkpToNetbackup_${DTATUAL}.log

        echo "`date` -> Inicio bkp fita..."
        echo "--------------------------------------------------"
        echo "PARAM_DIR.......:$PARAM_DIR"
        echo "PARAM_DES.......:$PARAM_DES"
        echo "NETBACKUP_CLIENT:$NETBACKUP_CLIENT"
        echo "NETBACKUP_POLICY:$NETBACKUP_POLICY"
        echo "NETBACKUP_SCHED.:$NETBACKUP_SCHED"
        echo "NETBACKUP_SERVER:$NETBACKUP_SERVER"
        echo "NETBACKUP_TYPE..:$NETBACKUP_TYPE"
        echo "NETBACKUP_LOG...:$NETBACKUP_LOG"
        echo "DTATUAL.........:$DTATUAL"
        echo "--------------------------------------------------"
        echo "...."
        ${NETBACKUP_CLIENT} -w -p ${NETBACKUP_POLICY} -s ${NETBACKUP_SCHED} -S ${NETBACKUP_SERVER} -t ${NETBACKUP_TYPE} -L ${NETBACKUP_LOG} -k "${PARAM_DES}" ${PARAM_DIR}
        RET=$?
        echo "`date` -> Retorno:$RET"
        if [ $RET = 0 ] ; then
           echo "Backup pra fita com sucesso."
        else
          echo "Backup pra fita com erro."
        fi

        echo "########## FINAL ENVIA FITA ######################"
}

controla_retencao()
{
        echo "########## INICIO CONTROLE RETENCAO ######################"

        echo "-> remover dumps"
        find $DMP_DIRDEST_BASE -name 'EXPORT_V7*' -ctime +7 -exec rm -rf {} \;

        echo "-> remover logs"
        find $DIR_LOG -name 'exp_v7*.log' -ctime +30 -exec rm -f {} \;

        echo "########## FINAL CONTROLE RETENCAO ######################"
}

echo "--------------------- INICIO PROCESSO `date +'%Y-%m-%d %k:%M:%S'` ------------------------------"

# Processo
reset_ambiente

export_schemas

envia_fita

controla_retencao

echo "--------------------- FINAL PROCESSO `date +'%Y-%m-%d %k:%M:%S'` ------------------------------"


} >> $LOG 2>&1

exit


