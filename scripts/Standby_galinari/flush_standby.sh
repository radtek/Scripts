#!/bin/bash

ENV_HOME=/home/oracle
SCRIPT_HOME=$ENV_HOME/ilegra/scripts/dgdc2
LOG=$SCRIPT_HOME/logs/dc2flush_varejo_`date +%Y%m%d%H%M`.log

. /home/oracle/varejo.env

echo "Start Flush at: "`date +%Y%m%d_%H%M` >> $LOG

DTF_PRD=`sqlplus -S system/madaga5car@VAREJODC1 <<EOF
set head off feedback off
select max(file#) from v\\\$datafile;
exit
EOF`

DTF_STD=`sqlplus -S / as sysdba <<EOF
set head off feedback off
select max(file#) from v\\\$datafile;
exit
EOF`

DIF_DTF=0
DIF_DTF=$(($DTF_PRD - $DTF_STD))

ST1=`sqlplus -S system/madaga5car@VAREJODC1 <<EOF
set head off feedback off
select max(sequence#) from v\\\$archived_log where deleted='YES' and thread#=1;
exit
EOF`

ST2=`sqlplus -S system/madaga5car@VAREJODC1 << EOF
set head off feedback off
select max(sequence#) from v\\\$archived_log where deleted='YES' and thread#=2;
exit
EOF`

if [ "$DIF_DTF" -le 0 ]
then

echo "Starting Recovery until Sequence "$ST1" Thread 1 and Sequence "$ST2" Thread 2 at: "`date +%Y%m%d_%H%M` >> $LOG
rman target=/ catalog rman/rman@rman <<EOF >> $LOG
run {
ALLOCATE CHANNEL C1 TYPE sbt;
send 'NB_ORA_SERV=srv-pae-bkp01,NB_ORA_POLICY=dc1-oracle-ost,NB_ORA_CLIENT=sv-dc1-ora01';
set until sequence $ST1 thread 1;
set until sequence $ST2 thread 2;
recover database delete archivelog;
}
exit;
EOF

else

CONT=0
LISTA=""
CMD_STNM=""
NEWLOC="+DATA"

while [ "$CONT" -le $DIF_DTF ];
do
if [ "$DIF_DTF" -le 1 ] 
then
LISTA=$((DTF_STD + $CONT))
CMD_STNM="SET NEWNAME FOR DATAFILE "$((DTF_STD + $CONT))" TO '$NEWLOC';"
else
if [ "$CONT" -le 1 ]
then
LISTA=$((DTF_STD + $CONT))
CMD_STNM="SET NEWNAME FOR DATAFILE "$((DTF_STD + $CONT))" TO '$NEWLOC';"
elif [ "$CONT" -le $DIF_DTF ]
then
LISTA=$LISTA","$((DTF_STD + $CONT))
CMD_STNM=$CMD_STNM" SET NEWNAME FOR DATAFILE "$((DTF_STD + $CONT))" TO '$NEWLOC';"
else
LISTA=$LISTA","$((DTF_STD + $CONT))","
CMD_STNM=$CMD_STNM" SET NEWNAME FOR DATAFILE "$((DTF_STD + $CONT))" TO '$NEWLOC';"
fi
fi
CONT=$((CONT + 1));
done;

echo "Starting restore of datafile(s): "$LISTA" And Recovery until Sequence "$ST1" Thread 1 and Sequence "$ST2" Thread 2 at: "`date +%Y%m%d_%H%M` >> $LOG
rman target=/ catalog rman/rman@rman <<EOF >>$LOG
run {
ALLOCATE CHANNEL C1 TYPE sbt;
send 'NB_ORA_SERV=srv-pae-bkp01,NB_ORA_POLICY=dc1-oracle-ost,NB_ORA_CLIENT=sv-dc1-ora01';
$CMD_STNM
restore datafile $LISTA;
switch datafile all;
set until sequence $ST1 thread 1;
set until sequence $ST2 thread 2;
recover database delete archivelog;
}
EOF

fi
echo "Stop Flush  at: " `date +%Y%m%d_%H%M` >> $LOG
fi
