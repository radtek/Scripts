#!/bin/bash

## Script que realiza bkp das configurações oracle:
# 1) Realiza um bkp das informações do Inventário Oracle, o que está instalado;
# 2) Realiza um bkp das configurações de Kernel do S.
# 3) Realiza um bkp dos arquivos de inicialização Oracle (inits.ora
# 4) Realiza um bkp dos status de cada um dos datafiles do banco
# 5) Realiza um export full sem linhas de todos os bancos que rodam no servidor.
#
# Gediel Luchetta - Immediate - Julho/2006
##

# Instancia as variáveis de ambiente
. /home/oracle/.bash_profile


# Variáveis de configuracao do script
ORATAB=/etc/oratab
BKPDIR=$ADM/bkp_conf
DIASRETENCAO=15
EXPUSR=bkp
#EXPPAS=bkp$ORACLE_SID
DATA=`date +'%Y-%m-%d'`
RETCODE=0

echo "${DATA}: Bkp das configurações Oracl
echo " "

# Bkp do OraInventory 10g
/usr/local/oracle/product/10.2.0/OPatch/opatch lsinventory -detail > ${BKPDIR}/bkp_orainventory_${DATA}.log 2>&1
grep "OPatch succeeded" ${BKPDIR}/bkp_orainventory_${DATA}.log > /dev/null 2>&1

RETCODE=$?
echo "OraInventory:"
echo "-------------------------------------"
cat ${BKPDIR}/bkp_orainventory_${DATA}.log
echo "-------------------------------------"
echo " "

# Bkp do OraInventory 12c
. /home/oracle/oraprev03.env
/usr/local/oracle/product/12.1.0/OPatch/opatch lsinventory -detail > ${BKPDIR}/bkp_orainventory_oraprev03_${DATA}.log 2>&1
grep "OPatch succeeded" ${BKPDIR}/bkp_orainventory_oraprev03_${DATA}.log > /dev/null 2>&1

RETCODE=$?
echo "OraInventory:"
echo "-------------------------------------"
cat ${BKPDIR}/bkp_orainventory_oraprev03_${DATA}.log
echo "-------------------------------------"
echo " "

# Bkp do sysctl.conf
cat /etc/sysctl.conf > ${BKPDIR}/bkp_sysctl_${DATA}.log 2>&1
echo "/etc/sysctl.conf:"
echo "-------------------------------------"
cat ${BKPDIR}/bkp_sysctl_${DATA}.log
echo "-------------------------------------"
echo " "

# Setanndo variavel para o banco 10g
. /home/oracle/.bash_profile

# Bkp dos inits e export full sem linhas dos bancos.
cat $ORATAB | while read LINE
do
    echo $LINE
    case $LINE in
        \#*)                ;;        #comment-line in oratab
        *)
        ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
        ORACLE_HOME=`echo $LINE | awk -F: '{print $2}' -`
        export ORACLE_SID
        export ORACLE_HOME

        if [ ! -z "$ORACLE_SID" ] ; then

           # Verifica a v$version
           $ORACLE_HOME/bin/sqlplus -s /nolog <<eof
spool ${BKPDIR}/bkp_version_${ORACLE_SID}_${DATA}.log
conn / as sysdba
select * from v\$version;
spool off;
exit;
eof
                                          