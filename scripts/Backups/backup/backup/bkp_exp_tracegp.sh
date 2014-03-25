. /home/oracle/.bash_profile
export ORACLE_SID=oraacct2

PREFIX=exp_tracegp_
OWNERS="TRACEGP"
DIR_DEST=/usr/local/oracle/oracledba/bkp_conf
DT=`date +%Y%m%d%H%M%S`
ARQ_DEST=${DIR_DEST}/${PREFIX}${DT}.dmp
LOG=${DIR_DEST}/${PREFIX}${DT}.log
RETENTION=3

exp userid=\'/ as sysdba\' file=${ARQ_DEST} owner=${OWNERS} log=${LOG} compress=n 

echo "Cleaning bkp files older than $RETENTION days..."
echo "find ${DIR_DEST} -name \"${PREFIX}*\" -mtime +${RETENTION} -print -exec rm {} \;"
find ${DIR_DEST} -name "${PREFIX}*" -mtime +${RETENTION} -print -exec rm {} \;
