####################################################################################################################
# Esse script recebe 3 parametros:
# 1) Owner
# 2) Table
# 3) Partition
# E dropa essa particao da tabela e em caso da particao estar sozinha na tablespace a tablespace tmb eh dropada.
#
####################################################################################################################
. /home/oracle/.bash_profile

DATA_ATUAL=`date +'%Y%m%d%H%M%S'`
WORK_DIR=$ORACLE_BASE/oracledba
DIR_SAIDA="${WORK_DIR}/logs"
RET_PROC=0
OWN=$1
TAB=$2
PAR=$3

if [ ! $# = 3 ] ; then
  echo " "
  echo "Deve ser passado 3 parametros:"
  echo "1o) Owner da tabela no banco."
  echo "2o) Nome da tabela no banco."
  echo "3o) Nome da particao a ser dropada."
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
begin
   system.pkg_sgp.prc_drop_partition (
        p_owner                 => '${OWN}',
        p_table_name            => '${TAB}',
        p_partition             => '${PAR}',
        p_drop_tablespaces      => TRUE);
end;
/
exit;
eof
RET_PROC=$?
if [ ${RET_PROC} = 0 ] ; then
  echo "Procedimento executado com sucesso."
else
  echo "Procedimento executado com erro."
fi
} > ${DIR_SAIDA}/drop_partition_${DATA_ATUAL}.log 2>&1
cat ${DIR_SAIDA}/drop_partition_${DATA_ATUAL}.log
exit ${RET_PROC}

