#!/bin/bash
LOG=/home/oracle/ilegra/scripts/dgdc2/logs/rebuild_dg_`date +%Y%m%d%H%M`.log

echo "Starting Rebuild Standby Database for Dataguard at "`date +'%d/%m/%Y %H:%M'` >> $LOG

echo "Shutdown Standby Varejo" >> $LOG
. /home/oracle/varejo.env
sqlplus -S / as sysdba <<EOF >> $LOG
shutdown immediate; 
exit
EOF

echo "Shutdown Standby Orarec" >> $LOG
. /home/oracle/orarec.env
sqlplus -S / as sysdba <<EOF >>$LOG
shutdown immediate;
exit
EOF

echo "Dropping Standby Databases" >> $LOG
. /home/oracle/crs.env

asmcmd rm -rf '+ARCH/varejodc2/onlinelog/*' >> $LOG
asmcmd rm -rf '+ARCH/varejodc2/archivelog/*' >> $LOG
asmcmd rm -rf '+DATA/varejodc2/tempfile/*' >> $LOG
asmcmd rm -rf '+DATA/varejodc2/controlfile/*' >> $LOG
asmcmd rm -rf '+DATA/varejodc2/datafile/*' >> $LOG 

asmcmd rm -rf '+ARCH/orarecdc2/onlinelog/*' >> $LOG
asmcmd rm -rf '+ARCH/orarecdc2/archivelog/*' >> $LOG
asmcmd rm -rf '+DATA/orarecdc2/tempfile/*' >> $LOG
asmcmd rm -rf '+DATA/orarecdc2/controlfile/*' >> $LOG
asmcmd rm -rf '+DATA/orarecdc2/datafile/*' >> $LOG

echo "Rebuilding Spfiles"
asmcmd rm -rf '+DATA/orarecdc2/spfileorarecdc2.ora' >> $LOG
. /home/oracle/orarec.env
sqlplus -S / as sysdba <<EOF >> $LOG
create spfile='+DATA/orarecdc2/spfileorarecdc2.ora' from pfile='/home/oracle/ilegra/files/initorarecdc2.ora';
exit
EOF

. /home/oracle/crs.env
asmcmd rm -rf '+DATA/varejodc2/spfilevarejodc2.ora' >> $LOG
. /home/oracle/varejo.env
sqlplus -S / as sysdba <<EOF >> $LOG
create spfile='+DATA/varejodc2/spfilevarejodc2.ora' from pfile='/home/oracle/ilegra/files/initvarejodc2.ora';
exit
EOF

echo "Putting standby databases in nomount" >> $LOG
. /home/oracle/varejo.env
sqlplus -S / as sysdba <<EOF >> $LOG
startup nomount;
exit
EOF

. /home/oracle/orarec.env
sqlplus -S / as sysdba <<EOF >> $LOG
startup nomount;
exit
EOF

echo "Stopping Rebuild Standby Database for Dataguard at "`date +'%d/%m/%Y %H:%M'` >> $LOG
