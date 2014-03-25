#!/bin/bash

ENV_HOME=/home/oracle
SCRIPT_HOME=$ENV_HOME/ilegra/scripts/clean_arch
LOG=$SCRIPT_HOME/logs/clear_orarec_`date +%Y%m%d%H%M`.log

. /home/oracle/orarec.env

#if ps -ef | grep "target=/ catalog rman/rman@rman" | grep -v grep;
#then	
#echo "clear ongoing"
#exit
#else
echo "Start Clear at: "`date +%Y%m%d_%H%M` >> $LOG

rman target=/  nocatalog <<EOF >>$LOG
ALLOCATE CHANNEL FOR MAINTENANCE TYPE DISK;
delete force noprompt archivelog until time 'SYSDATE-30/(24*60)';
EOF

echo "Stop Cleaning  at: " `date +%Y%m%d_%H%M` >> $LOG
fi
