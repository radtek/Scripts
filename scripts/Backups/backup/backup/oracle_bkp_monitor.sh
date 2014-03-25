#!/bin/sh
# Oracle Backup monitor check the following:
# 1) Check if exists datafiles that will need more than $NUM_DAYS of archived redo logs to be applied during recovery
# after being restored from the most recent backup;
# and
# 2) Check if exists datafiles that that require the application of $NUM_INC or more incremental backups to be recovered to their current state
#
# The script should receive 2 parameters: $NUM_DAYS and $NUM_INC 
#
# Monitor rule:
# if RET=0 THEN = Alarm OK
# if RET=2 THEN = Alarm ERROR
####################################################################################################################
. /home/oracle/.bash_profile

# This values can be a parameter of the script
NUM_DAYS=$1
NUM_INC=$2


RMAN_CMD="$ORACLE_HOME/bin/rman TARGET=/ nocatalog"
MONIT="REPORT NEED BACKUP DAYS ${NUM_DAYS} DATABASE;"
EXPECT_RESULT="File Days"
NOK_RET=2
NOK_MSG="Error on backup oracle monitor (${MONIT})"
RET=0
MSG="Monitor Backup oracle is OK."
TMPLOG=/tmp/monit_ora_bkp1.log
> $TMPLOG

{
$RMAN_CMD TRACE=${TMPLOG} <<eof
$MONIT
exit;
eof
}
RET=$?

if [ $RET = 0 ] ; then
   VTMP=`tail -6 ${TMPLOG} | head -1`
   echo $VTMP | grep "${EXPECT_RESULT}"  > /dev/null 2>&1
   RET=$?
   if [ ! $RET = 0 ] ; then
      RET=${NOK_RET}
      MSG=${NOK_MSG}
   fi
else
   RET=${NOK_RET}
   MSG=${NOK_MSG}
fi

if [ $RET = 0 ] ; then

   RMAN_CMD="$ORACLE_HOME/bin/rman TARGET=/ nocatalog"
   MONIT="REPORT NEED BACKUP INCREMENTAL ${NUM_INC} DATABASE;"
   EXPECT_RESULT="File Incrementals"
   NOK_RET=2
   NOK_MSG="Error on backup oracle monitor (${MONIT})"
   TMPLOG=/tmp/monit_ora_bkp2.log
   > $TMPLOG
   {
    $RMAN_CMD TRACE=${TMPLOG} <<eof
$MONIT
exit;
eof
   }
   RET=$?

   if [ $RET = 0 ] ; then
      VTMP=`tail -6 ${TMPLOG} | head -1`
      echo $VTMP | grep "${EXPECT_RESULT}"  > /dev/null 2>&1
      RET=$?
      if [ ! $RET = 0 ] ; then
         RET=${NOK_RET}
         MSG=${NOK_MSG}
      fi
   else
      RET=${NOK_RET}
      MSG=${NOK_MSG}
   fi
fi

### Return the result
echo "RET=${RET}"
echo "MSG=${MSG}"
exit $RET
