#!/bin/bash

ENV_HOME=/home/oracle
SCRIPT_HOME=$ENV_HOME/ilegra/scripts/dgdc2
LOG=$SCRIPT_HOME/logs/duplicate_orarec`date +%Y%m%d`.log

. $ENV_HOME/orarec.env
echo "START VAREJO DUPLICATE AT: "`date +%Y%m%d%H%M` >> $LOG
echo ""
echo ""
rman target=sys/madaga5car@ORARECDC1 auxiliary=sys/madaga5car@STBY_ORAREC catalog rman/rman@rman log=$LOG @/home/oracle/ilegra/scripts/dgdc2/duplicate_orarec.rman
echo ""
echo ""
echo "STOP VAREJO DUPLICATE AT: "`date +%Y%m%d%H%M` >> $LOG
