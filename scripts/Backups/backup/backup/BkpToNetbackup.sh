#!/bin/sh
# Script que envia o conteudo de um diretorio para backup em fita no Servidor Netbackup Server e se foi ok, remove o diretorio.
# Recebe como parametro duas informacoes:
# 1) Diretorio que deve copiar (todos os arquivos e subdiretorios presentes dentro) e remover caso tenha feito o bkp ok;
# 2) Uma descricao de como deve ficar registrado o bkp
# Gediel - ilegra - 2009-08-24
#
if [ ! $# -eq 2 ] ; then
   echo
   echo "Deve ser passado 2 parametros:"
   echo " 1) Diretorio que deve copiar (todos os arquivos e subdiretorios presentes dentro) e remover caso tenha feito o bkp ok;"
   echo " 2) Uma descricao de como deve ficar registrado o bkp."
   echo 
   exit 1
fi
 
NETBACKUP_CLIENT="/usr/openv/netbackup/bin/bparchive"
NETBACKUP_POLICY="morto-oracle"
NETBACKUP_SCHED="morto"
NETBACKUP_SERVER="bkp-master01-mia.bkp.terra.com"
NETBACKUP_TYPE=0 
PARAM_DIR=$1
PARAM_DES=$2
DTATUAL=`date +'%Y%m%d_%H%M%S'`
NETBACKUP_LOG=/usr/local/oracle/oracledba/logs/BkpToNetbackup_${DTATUAL}.log

echo "`date` -> Inicio bkp fita..."
echo "--------------------------------------------------"
echo "PARAM_DIR.......:$PARAM_DIR"
echo "PARAM_DES.......:$PARAM_DES"
echo "NETBACKUP_CLIENT:$NETBACKUP_CLIENT"
echo "NETBACKUP_POLICY:$NETBACKUP_POLICY"
echo "NETBACKUP_SCHED.:$NETBACKUP_SCHED"
echo "NETBACKUP_SERVER:$NETBACKUP_SERVER"
echo "NETBACKUP_TYPE..:$NETBACKUP_TYPE"
echo "NETBACKUP_LOG...:$NETBACKUP_LOG"
echo "DTATUAL.........:$DTATUAL"
echo "--------------------------------------------------"
echo "...."
${NETBACKUP_CLIENT} -w -p ${NETBACKUP_POLICY} -s ${NETBACKUP_SCHED} -S ${NETBACKUP_SERVER} -t ${NETBACKUP_TYPE} -L ${NETBACKUP_LOG} -k "${PARAM_DES}" ${PARAM_DIR}
RET=$?
echo "`date` -> Retorno:$RET"
if [ $RET = 0 ] ; then
   echo "Backup pra fita com sucesso."
else
   echo "Backup pra fita com erro."
fi
exit $RET
