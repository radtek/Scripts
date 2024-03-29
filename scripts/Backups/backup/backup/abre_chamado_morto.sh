MAIL="/tmp/mail.msg"
DIR_DMPS="/home/oracle/bkp/dmp"
SUB="Morto na `hostname` com posterior remocao."
### Informacoes p/ envio de email que abre o chamado ###
EMAILSCRIPT="/usr/local/oracle/oracledba/backup/SendEmail"
#EMAILFROM="gediel.luchetta@corp.terra.com.br"
EMAILFROM="gediel.luchetta.ilegra@terc.terra.com.br"
EMAILTO="ticket.core@corp.terra.com.br"
EMAILCC="Dba@corp.terra.com.br"
EMAILSERVER="smtp.corp.terra.com.br"

if [ -z "$1" ] ; then
  # Descobre a competencia mais antiga que tem pra processar
  PAR=`ls -tr ${DIR_DMPS}/MENORQ_*dmp* | head -1 | cut -c 29-36`
else
  PAR=`echo $1 | cut -c 8-15`
fi

TAM=`du -shc ${DIR_DMPS}/MENORQ_${PAR}*dmp* | grep total | cut -c 1-5`

# Descobre o Ano/Mes da competencia que vai pra morto.
ANO_PAR=`echo $PAR | cut -c 1-4`
MES_PAR=`echo $PAR | cut -c 5-6`

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

{
echo "Categoria = Servicos Internos"
echo "SubCategoria = Backup"
echo "Opcao = Backup Morto"
echo "Prioridade = Severity 2"
echo "Assunto = ${SUB} "
echo "Maquina....:`hostname`"
echo "Tamanho....:${TAM}"
echo "Frase-chave:ORAEXP accounting-${MES_COM}${ANO_COM}"
echo "Descricao..:Backup l�gico (export) da parti��o de $MES_COM de $ANO_COM da tabela acct.trr_movimentos (accounting)."
echo "Arquivos...:"
echo "-------------------------------"
ls -ltr ${DIR_DMPS}/MENORQ_${PAR}*dmp*
echo "-------------------------------"
echo "!!! Importante !!!"
echo "Apos morto efetuado, os arquivos DEVEM SER REMOVIDOS da `hostname` para liberar espa�o em disco."
echo "Obrigado."
} > $MAIL

###mail -s "${SUB}" $LISTA < $MAIL
${EMAILSCRIPT} -f ${EMAILFROM} -t ${EMAILTO} -cc ${EMAILCC} -s ${EMAILSERVER} -v -u "$SUB" -m "`cat ${MAIL}`" 
