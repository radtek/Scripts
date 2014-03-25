MAIL="/tmp/mail.msg"
WORK=/usr/local/oracle/oracledba/backup
DIR_DMPS="/home/oracle/bkp/dmp"
SUB="Morto na `hostname` com posterior remocao."
### Informacoes p/ envio de email que abre o chamado ###
EMAILSCRIPT="$WORK/SendEmail"
EMAILFROM="gediel.luchetta@corp.terra.com.br"
EMAILTO="ticket.core@corp.terra.com.br"
EMAILCC="Dba@corp.terra.com.br"
EMAILSERVER="smtp.corp.terra.com.br"



# Descobre a competencia mais antiga que tem pra processar
PAR=$1
ARQ=$2
OWN=$3
TAB=$4

TAM=`du -shc ${ARQ} | grep total | cut -c 1-5`

# Descobre o Ano/Mes da competencia que vai pra morto.
ANO_PAR=`echo $PAR | cut -c 8-11`
MES_PAR=`echo $PAR | cut -c 12-13`

if [ "$MES_PAR" = "01" ] ; then
   ANO_COM=`expr $ANO_PAR - 1`
   MES_COM="DEZ"
else
   ANO_COM=$ANO_PAR
   if [ "$MES_PAR" = "02" ] ; then
      MES_COM="JAN"
   else
      if [ "$MES_PAR" = "03" ] ; then
         MES_COM="FEV"
      else
         if [ "$MES_PAR" = "04" ] ; then
            MES_COM="MAR"
         else
            if [ "$MES_PAR" = "05" ] ; then
               MES_COM="ABR"
            else
               if [ "$MES_PAR" = "06" ] ; then
                  MES_COM="MAI"
               else
                  if [ "$MES_PAR" = "07" ] ; then
                     MES_COM="JUN"
                  else
                     if [ "$MES_PAR" = "08" ] ; then
                        MES_COM="JUL"
                     else
                        if [ "$MES_PAR" = "09" ] ; then
                           MES_COM="AGO"
                        else
                           if [ "$MES_PAR" = "10" ] ; then
                              MES_COM="SET"
                           else
                              if [ "$MES_PAR" = "11" ] ; then
                                 MES_COM="OUT"
                              else
                                 if [ "$MES_PAR" = "12" ] ; then
                                    MES_COM="NOV"
                                 fi
                              fi
                           fi
                        fi
                     fi
                  fi
               fi
            fi
         fi
      fi
   fi
fi

if [ "${TAB}" = "FTO_ACCOUNT_MES" ] ; then
   CHAVE="ORAEXP FTO_ACCTMES-${MES_COM}${ANO_COM}"
else
   if [ "${TAB}" = "FTO_ACCOUNT_FOMENTO" ] ; then
      CHAVE="ORAEXP FTO_ACCTFOM-${MES_COM}${ANO_COM}"
   else
      CHAVE="ORAEXP ${TAB}-${MES_COM}${ANO_COM}"
   fi
fi

{
echo "Categoria = Servicos Internos"
echo "SubCategoria = Backup"
echo "Opcao = Backup Morto"
echo "Prioridade = Severity 2"
echo "[assunto] = ${SUB} "
echo "Maquina....:`hostname`"
echo "Tamanho....:${TAM}"
echo "Frase-chave:${CHAVE}"
echo "Descricao..:Backup l�gico (export) da parti��o de $MES_COM de $ANO_COM da tabela ${OWN}.${TAB}."
echo "Arquivos...:"
echo "-------------------------------"
ls -ltr ${ARQ}
echo "-------------------------------"
echo " "
echo "!!! Importante !!!"
echo "Apos morto efetuado, 2 procedimentos devem ser realizados na `hostname`:" 
echo "1-) Remover os arquivos copiados para liberar espa�o em disco."
echo "2-) Logado com root executar o seguinte comando:"
echo " "
echo "su - oracle -c \"$WORK/drop_old_partition.sh ${OWN} ${TAB} ${PAR}\""
echo " "
echo "Colar a saida de tela desse comando acima no fechamento desse chamado." 
echo "Obrigado."
echo " "
} > $MAIL
#mail -s "${SUB}" $LISTA < $MAIL
${EMAILSCRIPT} -f ${EMAILFROM} -t ${EMAILTO} -cc ${EMAILCC} -s ${EMAILSERVER} -v -u "$SUB" -m "`cat ${MAIL}`" 

