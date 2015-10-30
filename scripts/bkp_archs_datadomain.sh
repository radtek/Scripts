. /home/oracle/.bash_profile
. /home/oracle/db.env
DT=`date +'%Y%m%d_%H%M%S'`; export DT                                     # Formata data para o log


{
echo "Inicio do backup"
uptime
rman target / catalog RMAN/TRR_RMAN_123@oracat<<EOF
RUN {
    ALLOCATE CHANNEL C1 TYPE SBT_TAPE PARMS
        'SBT_LIBRARY=/usr/local/oracle/product/12.1.0.1.0/lib/libddobk.so';
        send 'set username ddboost password bkp10trr servername bkp-dd01-mia.bkp.terra.com';
    RELEASE CHANNEL C1;
}
SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';
BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL FORMAT 'ARCH_CMS_%d_%s_%p_%T.rmn' DELETE ALL INPUT;
BACKUP CURRENT CONTROLFILE FORMAT 'CTL_CMS_%d_%s_%p_%T.rmn';
exit;
EOF
RET_RMAN_BD=$?
echo "Fim do backup"
uptime
} >> /home/oracle/ilegra/bkp_datadomain/log/Archs_rman_datadomain_${DT}.log
~
