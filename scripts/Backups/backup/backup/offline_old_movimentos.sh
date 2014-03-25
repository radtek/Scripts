####################################################################################################################
# Script que passa tablespaces para offline, realiza bkp morto e remove os datafiles do disco.
# Esse script busca a particao exatamente 12 meses atraz da TRR_MOVIMENTOS e a coloca offline.
# Obs: Muito cuidado ao executar esse script.
# Se não estiver certo da execução é melhor falar com um DBA antes.
####################################################################################################################
. /home/oracle/.bash_profile

DATA_ATUAL=`date +'%Y%m%d%H%M%S'`
WORK_DIR=$ORACLE_BASE/oracledba
DIR_SAIDA="${WORK_DIR}/logs"
ARQ_SAIDA="lista_tbs_offline.${DATA_ATUAL}"
RET_PROC=0


OFFLINE_TBS ()
{
TBS=$1
ARQ=${DIR_SAIDA}/rm_dtf_${TBS}.tmp
ARQ2=${DIR_SAIDA}/rm_dtf_${TBS}.sh

sqlplus /nolog <<eof
conn / as sysdba
set echo on
set timing on
set time on
whenever sqlerror exit 1
whenever oserror exit 2
alter tablespace ${TBS} offline;
prompt Vai gerar comandos de rm dentro do arquivo  ${ARQ}
spool ${ARQ}
set head off
set feed off
select 'rm '||file_name from dba_data_files where tablespace_name = '${TBS}';
spool off;
exit
eof

echo "Arquivo  ${ARQ} gerado com os comandos de remocao"
cat ${ARQ} 
echo "Vai limpar o arquivo ${ARQ} e gerar ${ARQ2} "
cat ${ARQ} | grep rm | grep -v select > ${ARQ2}
cat ${ARQ2} 
chmod u+x ${ARQ2}
${ARQ2}
}

# Gera a lista de tablespace que devem passar para Offline
sqlplus /nolog <<eof
conn / as sysdba
set echo off
set feed off
set termout off
set head off
spool ${DIR_SAIDA}/${ARQ_SAIDA}
SELECT 'Data tablespace:' || TABLESPACE_NAME || chr(10) ||'Indx tablespace:' || replace(tablespace_name,'DATA','INDX')
  FROM DBA_TAB_PARTITIONS A
 WHERE A.TABLE_NAME  = 'TRR_MOVIMENTOS'
   AND A.TABLE_OWNER         = 'ACCT'
   AND SUBSTR(A.PARTITION_NAME,8,8) = TO_CHAR(ADD_MONTHS(trunc(sysdate,'MM'),-12),'YYYYMMDD');
spool off;
exit;
eof

# Pega as tablespaces que foram gravadas no arquivo.
# Para cada uma passa para offline e remove os datafiles do Disco.
LIST_TBS=`cat ${DIR_SAIDA}/${ARQ_SAIDA} | grep tablespace | grep -v SELECT | cut -c 17-`
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
