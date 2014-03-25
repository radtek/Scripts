####################################################################################################################
# Script que passa tablespaces para offline, realiza bkp morto e remove os datafiles do disco.
# Esse script se baseia nas configurações que estão na tabela SYSTEM.PARTICAO_TAB_CONFIG, mais
# especificamente no campo NRO_PARTICOES_READ_ONLY. Se a tabela possuir mais particoes em tablespace
# Read Only que o especificado nesse campo ele passa todas as particoes mais antigas nessas condições para offline.
# Obs: Muito cuidado ao executar esse script.
# Se não estiver certo da execução é melhor falar com um DBA antes.
####################################################################################################################
DATA_ATUAL=`date +'%Y%m%d%H%M%S'`
WORK_DIR=$ORACLE_BASE/oracledba
DIR_SAIDA="${WORK_DIR}/logs"
ARQ_SAIDA="lista_tbs_offline.${DATA_ATUAL}"
RET_PROC=0


OFFLINE_TBS ()
{
TBS=$1
ARQ=${DIR_SAIDA}/rm_dtf_${TBS}.sh

sqlplus /nolog <<eof
conn / as sysdba
set echo on
set timing on
set time on
whenever sqlerror exit 1
whenever oserror exit 2
alter tablespace ${TBS} offline;
spool ${ARQ}
set head off
set feed off
select 'rm '||file_name from dba_data_files where tablespace_name = '${TBS}';
spool off;
eof
exit

cat ${ARQ} | grep rm | grep -v select > ${ARQ}
chmod u+x ${ARQ}
${ARQ}
}

# Chama procedure para gerar a lista de tablespace que devem passar para Offline
sqlplus /nolog <<eof
conn / as sysdba
exec system.pkg_sgp.prc_gera_lista_tbs_of(P_DIRETORIO_SAIDA => '${DIR_SAIDA}', P_ARQUIVO_SAIDA => '${ARQ_SAIDA}');
exit;
eof

# Pega as tablespaces que foram gravadas no arquivo.
# Para cada uma passa para offline e remove os datafiles do Disco.
LIST_TBS=`cat ${DIR_SAIDA}/${ARQ_SAIDA}`
for L in ${LIST_TBS}
do
	echo "Processando tablespace $L.."
	echo "Realiza bkp morto:"
	${WORK_DIR}/backup/bkp_morto_tbl.sh ${WORK_DIR}/backup/bkp_${ORACLE_SID}.conf "${L}"
	if [ $? = 0 ] ; then
		echo "Passa tablespace para offline e remove os datafiles:"
        	OFFLINE_TBS ${L}
	else

		echo "Erro ao efetuar bkp morto da tablespace ${L}, não será passada para offline."
		RET_PROC=1
	fi
	echo "Final do processamento da tablespace ${L}."
done
exit ${RET_PROC}
