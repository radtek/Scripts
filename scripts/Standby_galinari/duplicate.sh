#!/bin/bash

ENV_HOME=/home/oracle
SCRIPT_HOME=$ENV_HOME/ilegra/scripts/dgdc2
LOG=$SCRIPT_HOME/logs/duplicate_varejo_`date +%Y%m%d`.log

. $ENV_HOME/varejo.env
echo "START DUPLICATE AT: "`date +%Y%m%d%H%M` >> $LOG
echo ""
echo ""
rman target=sys/madaga5car@VAREJODC1 auxiliary=sys/madaga5car@STBY_VAREJO catalog rman/rman@rman log=$LOG @/home/oracle/ilegra/scripts/dgdc2/duplicate.rman
echo ""
echo ""
echo "STOP DUPLICATE AT: "`date +%Y%m%d%H%M` >> $LOG
