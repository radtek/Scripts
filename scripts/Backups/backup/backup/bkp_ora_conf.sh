#!/bin/bash

## Script que realiza bkp das configurações oracle:
# 1) Realiza um bkp das informações do Inventário Oracle, o que está instalado;
# 2) Realiza um bkp das configurações de Kernel do S.O;
# 3) Realiza um bkp dos arquivos de inicialização Oracle (inits.ora);
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
EXPUSR=$1
EXPPAS=$2
DATA=`date +'%Y-%m-%d'`
RETCODE=0

echo "${DATA}: Bkp das configurações Oracle"
echo " "

# Bkp do OraInventory
opatch lsinventory -detail > ${BKPDIR}/bkp_orainventory_${DATA}.log 2>&1
grep "OPatch succeeded" ${BKPDIR}/bkp_orainventory_${DATA}.log > /dev/null 2>&1
RETCODE=$?
echo "OraInventory:"
echo "-------------------------------------"
cat ${BKPDIR}/bkp_orainventory_${DATA}.log
echo "-------------------------------------"
echo " "

# Bkp do sysctl.conf
cat /etc/sysctl.conf > ${BKPDIR}/bkp_sysctl_${DATA}.log 2>&1
echo "/etc/sysctl.conf:"
echo "-------------------------------------"
cat ${BKPDIR}/bkp_sysctl_${DATA}.log
echo "-------------------------------------"
echo " "

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

           # Bkp dos parametro de inicializacao da instance.
           {
           cat $ORACLE_HOME/dbs/init${ORACLE_SID}.ora
           strings $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora
           } > ${BKPDIR}/bkp_init_${ORACLE_SID}_${DATA}.log 2>&1
           SPFILE2=`cat $ORACLE_HOME/dbs/init${ORACLE_SID}.ora | grep -i spfile | awk -F= '{print $2}'`
           echo "Spfile2: $SPFILE2"
           if [ ! -z "${SPFILE2}" ] ; then
             strings ${SPFILE2} >> ${BKPDIR}/bkp_init_${ORACLE_SID}_${DATA}.log 2>&1
           fi
           echo "init $ORACLE_SID:"
           echo "-------------------------------------"
           cat ${BKPDIR}/bkp_init_${ORACLE_SID}_${DATA}.log
           echo "-------------------------------------"
           echo " "
echo "Datafile status"
echo "-------------------------------------"
           # Lista status dos datafiles do banco 
           $ORACLE_HOME/bin/sqlplus -s /nolog <<eof
           spool ${BKPDIR}/bkp_datafiles_${ORACLE_SID}_${DATA}.log
           conn / as sysdba
           set lines 250
	   set pages 10000
           col name for a100
           select file#, name, status, enabled from v\$datafile
           order by status,enabled, file#;
           spool off;
           exit;
eof
echo "-------------------------------------"
echo " "
           # Realiza export full sem linhas do banco.
           if [ -z "${EXPUSR}" ] ; then
             U=bkp
           else
             U=${EXPUSR}
           fi
           if [ -z "${EXPPAS}" ] ; then
             P=bkp$ORACLE_SID
           else
             P=${EXPPAS}
           fi
           $ORACLE_HOME/bin/exp ${U}/${P} file=${BKPDIR}/bkp_expfull_nrows_${ORACLE_SID}.dmp full=y rows=n > ${BKPDIR}/bkp_expfull_nrows_${ORACLE_SID}.log 2>&1
           grep "Export terminated successfully" ${BKPDIR}/bkp_expfull_nrows_${ORACLE_SID}.log > /dev/null 2>&1
	   RETCODE=$?
           if [ $RETCODE != 0 ] ; then
             exit $RETCODE
           fi
	   echo "Exp full sem linhas do $ORACLE_SID:"
           echo "-------------------------------------"
           echo "Gerado em ${BKPDIR}/bkp_expfull_nrows_${ORACLE_SID}.dmp"
           echo "-------------------------------------"
           echo " "
	fi
        ;;
    esac
done
RETCODE=$?
if [ $RETCODE = 0 ] ; then
  echo "Script executado com sucesso"
else
  echo "Erro na execução do script, verifique as saídas."
fi

find ${BKPDIR} -ctime +${DIASRETENCAO} -exec rm {} \;

exit $RETCODE
