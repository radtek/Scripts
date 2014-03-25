
DIRBKP=/u/local/oracle/oracledba/backup
RET=0

sqlplus /nolog @$DIRBKP/gstat.sql
RET=$?
if [ $RET = 0 ] ; then
   sqlplus /nolog @$DIRBKP/stat.sql
   RET=$?
fi
exit $RET
