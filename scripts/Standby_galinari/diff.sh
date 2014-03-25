#!/bin/bash
. /home/oracle/varejo.env
DIFF_PATH=/home/oracle/ilegra/scripts/monitoracao_dg
rm $DIFF_PATH/diff_t1.txt

SEQ_PRD_T1=`sqlplus -S system/madaga5car@varejodc1 << EOF
set head off
SELECT SEQUENCE# FROM V\\\$THREAD where thread#=1;
exit;
EOF`

SEQ_STD_T1=`sqlplus -S / as sysdba << EOF
set head off
SELECT MAX(SEQUENCE#) FROM V\\\$ARCHIVED_LOG WHERE APPLIED = 'YES' AND RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V\\\$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') and thread#=1;
exit;
EOF`

DIF_SEQ_T1=$(($SEQ_PRD_T1 - $SEQ_STD_T1))

echo $DIF_SEQ_T1\|Standby > $DIFF_PATH/diff_t1.txt

rm $DIFF_PATH/diff_t2.txt

SEQ_PRD_T2=`sqlplus -S system/madaga5car@varejodc1 << EOF
set head off
SELECT SEQUENCE# FROM V\\\$THREAD where thread#=2;
exit;
EOF`

SEQ_STD_T2=`sqlplus -S / as sysdba << EOF
set head off
SELECT MAX(SEQUENCE#) FROM V\\\$ARCHIVED_LOG WHERE APPLIED = 'YES' AND RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V\\\$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') and thread#=2;
exit;
EOF`

DIF_SEQ_T2=$(($SEQ_PRD_T2 - $SEQ_STD_T2))

echo $DIF_SEQ_T2\|Standby > $DIFF_PATH/diff_t2.txt
####ORAREC

. /home/oracle/orarec.env
DIFF_PATH=/home/oracle/ilegra/scripts/monitoracao_dg
rm $DIFF_PATH/diff_t1_orarec.txt

SEQ_PRD_T1=`sqlplus -S system/madaga5car@orarecdc1 << EOF
set head off
SELECT SEQUENCE# FROM V\\\$THREAD where thread#=1;
exit;
EOF`

SEQ_STD_T1=`sqlplus -S / as sysdba << EOF
set head off
SELECT MAX(SEQUENCE#) FROM V\\\$ARCHIVED_LOG WHERE APPLIED = 'YES' AND RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V\\\$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') and thread#=1;
exit;
EOF`

DIF_SEQ_T1=$(($SEQ_PRD_T1 - $SEQ_STD_T1))

echo $DIF_SEQ_T1\|Standby > $DIFF_PATH/diff_t1_orarec.txt

rm $DIFF_PATH/diff_t2_orarec.txt

SEQ_PRD_T2=`sqlplus -S system/madaga5car@orarecdc1 << EOF
set head off
SELECT SEQUENCE# FROM V\\\$THREAD where thread#=2;
exit;
EOF`

SEQ_STD_T2=`sqlplus -S / as sysdba << EOF
set head off
SELECT MAX(SEQUENCE#) FROM V\\\$ARCHIVED_LOG WHERE APPLIED = 'YES' AND RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE# FROM V\\\$DATABASE_INCARNATION WHERE STATUS = 'CURRENT') and thread#=2;
exit;
EOF`

DIF_SEQ_T2=$(($SEQ_PRD_T2 - $SEQ_STD_T2))

echo $DIF_SEQ_T2\|Standby > $DIFF_PATH/diff_t2_orarec.txt

