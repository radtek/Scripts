####################################################################################################################
# Esse script recebe 2 parametros:
# 1) Partition
# 2) Tablespace
# Realiza o rebuild os indices dessa particao pra uma tablespace temporaria e depois volta pra tablespace original.
#
####################################################################################################################
DATA_ATUAL=`date +'%Y%m%d%H%M%S'`
WORK_DIR=$ORACLE_BASE/oracledba
DIR_SAIDA="${WORK_DIR}/logs"
RET_PROC=0
PAR=$1
TBS=$2

if [ ! $# = 2 ] ; then
  echo " "
  echo "Deve ser passado 2 parametros:"
  echo "1o) Particao"
  echo "2o) Tablespace final"
  echo " "
  exit 1
fi



# Chama procedure para gerar a lista de tablespace que devem passar para Offline
{
sqlplus /nolog <<eof
conn / as sysdba
set echo on
set timing on
set time on
whenever sqlerror exit 1
whenever oserror  exit 2
-----
alter index acct.MOVI_DTCHEGADA_IDX rebuild partition ${PAR} Tablespace tbs_rebuild_tmp Nologging Online;
alter index acct.MOVI_IPASSINALADO_IDX rebuild partition ${PAR} Tablespace tbs_rebuild_tmp Nologging Online;
alter index acct.PK_TRR_MOVIMENTOS rebuild partition ${PAR} Tablespace tbs_rebuild_tmp Nologging Online;
-----
alter index acct.MOVI_DTCHEGADA_IDX rebuild partition ${PAR} Tablespace ${TBS} Nologging Online Compute Statistics;
alter index acct.MOVI_IPASSINALADO_IDX rebuild partition ${PAR} Tablespace ${TBS}  Nologging Online Compute Statistics;
alter index acct.PK_TRR_MOVIMENTOS rebuild partition ${PAR} Tablespace ${TBS} Nologging Online Compute Statistics;
-----
exit;
eof
RET_PROC=$?
if [ ${RET_PROC} = 0 ] ; then
  echo "Procedimento executado com sucesso."
else
  echo "Procedimento executado com erro."
fi
} > ${DIR_SAIDA}/rebuild_mov_idx_${DATA_ATUAL}.log 2>&1
cat ${DIR_SAIDA}/rebuild_mov_idx_${DATA_ATUAL}.log
exit ${RET_PROC}

