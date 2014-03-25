####################################################################################################################
# Script que passa tablespaces para readonly e realiza bkp morto. 
# Esse script se baseia nas configurações que estão na tabela SYSTEM.PARTICAO_TAB_CONFIG, mais
# especificamente no campo NRO_PARTICOES_READ_WRITE. Se a tabela possuir mais particoes em tablespace
# Read write que o especificado nesse campo ele passa todas as particoes mais antigas nessas condições para readonly.
# Obs: Muito cuidado ao executar esse script.
# Se não estiver certo da execução é melhor falar com um DBA antes.
####################################################################################################################
. /home/oracle/.bash_profile

DATA_ATUAL=`date +'%Y%m%d%H%M%S'`
WORK_DIR=$ORACLE_BASE/oracledba
DIR_SAIDA="${WORK_DIR}/logs"
ARQ_SAIDA="lista_tbs_readonly.${DATA_ATUAL}"
RET_PROC=0
DATA_PAR=$1
if [ -z "${DATA_PAR}" ] ; then
   DATA_PAR="SYSDATE"
fi

BUSCA_PARTICAO ()
{
#
# Funcao que busca o partition name com base num parametro de tablespace
#
TBS=$1
OWN="ACCT"
TAB="TRR_MOVIMENTOS"

pega_do_banco ()
{
# Executa o plus para pegar o destino dinamicamente
sqlplus /nolog  <<EOF
connect / as sysdba
set head off
select 'PART='|| Partition_name
  from dba_segments
 where owner = '${OWN}'
   and segment_name = '${TAB}' 
   and tablespace_name = '${TBS}'
   and segment_type = 'TABLE PARTITION';
exit;
EOF
}
echo `pega_do_banco | grep PART= | awk -F= '{print $2}'`
}


READONLY_TBS ()
{
TBS=$1
sqlplus /nolog <<eof
conn / as sysdba
set echo on
set timing on
set time on
whenever sqlerror exit 1
whenever oserror exit 2
exec system.pkg_sgp.prc_read_only_tablespace('${TBS}'); 
exit;
eof
}

# Chama procedure para gerar a lista de tablespace que devem passar para Offline
sqlplus /nolog <<eof
conn / as sysdba
begin
  system.pkg_sgp.prc_gera_lista_tbs_ro (
	P_DATA_REFERENCIA => ${DATA_PAR}, 
	P_DIRETORIO_SAIDA => '${DIR_SAIDA}', 
	P_ARQUIVO_SAIDA => '${ARQ_SAIDA}');
end;
/

exit;
eof

if [ ! -f ${DIR_SAIDA}/${ARQ_SAIDA} ] ; then
   echo "Nenhuma tablespace a ser processada."
   exit 0
fi

# Pega as tablespaces que foram gravadas no arquivo.
# Para cada uma passa para readonly e realiza bkp morto..
LIST_TBS=`cat ${DIR_SAIDA}/${ARQ_SAIDA}`
for L in ${LIST_TBS}
do
	echo "Processando tablespace $L.."
	echo "Passa tablespace para read Only:"
	READONLY_TBS ${L}
	if [ $? = 0 ] ; then
		echo "Realiza bkp morto:"
		${WORK_DIR}/backup/bkp_morto_tbl.sh ${WORK_DIR}/backup/bkp_${ORACLE_SID}.conf "${L}"
                if [ ! $? = 0 ] ; then
                   RET_PROC=1
                fi
                ## Verifica se eh uma tablespace de dados, se for realiza o export dessa particao
                echo ${L} | grep ACCT_MOV_DATA > /dev/null 2>&1
		if [ $? = 0 ] ; then
		   PART=`BUSCA_PARTICAO ${L}`
                   echo "Vai realizar o export da particao: $PART"
                   # Executa um export da particao
		   $ADM/rotinas/exp_ult_part_movimentos.sh $PART 
                   if [ $? = 0 ] ; then
                      # Abre chamado p/ realizacao de morto dos arquivos gerados pelo Export
                      $ADM/backup/bkp_morto_export.sh $PART
                      if [ $? = 0 ] ; then
                         echo "Backup morto pra fita realizado com sucesso!"
                      else
                         echo "Erro realizando bkp morto pra fita da particao $PART."
                         RET_PROC=1
                      fi
                   else
                      echo "Erro no export da particao $PART"
                      RET_PROC=1
                   fi
		fi	
                   
	else
		echo "Erro ao passar tablespace ${L} para read only."
		RET_PROC=1
	fi
	echo "Final do processamento da tablespace ${L}."
done
exit ${RET_PROC}
