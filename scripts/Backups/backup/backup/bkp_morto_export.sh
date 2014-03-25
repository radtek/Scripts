DIR_DMPS="/home/oracle/bkp/dmp"
BKPSCRIPT="/usr/local/oracle/oracledba/backup/BkpToNetbackup.sh"
DTATUAL=`date +'%Y%m%d_%H%M%S'`
DIR_TMP=$DIR_DMPS/enviando_pra_fita_${DTATUAL}

if [ -z "$1" ] ; then
  # Descobre a competencia mais antiga que tem pra processar
  PAR=`ls -tr ${DIR_DMPS}/MENORQ_*dmp* | head -1 | cut -c 29-36`
else
  PAR=`echo $1 | cut -c 8-15`
fi

TAM=`du -shc ${DIR_DMPS}/MENORQ_${PAR}*dmp* | grep total | cut -c 1-5`

# Move os arquivos para um diretorio temporario para serem enviados pro netbackup.
# O script que envia pro netbackup remove o diretorio (e seus arquivos) caso o bkp finalize com sucesso.
mkdir ${DIR_TMP}
mv ${DIR_DMPS}/MENORQ_${PAR}*dmp* ${DIR_TMP}/


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

${BKPSCRIPT} ${DIR_TMP} "ORAEXP accounting-${MES_COM}${ANO_COM}"
$RET=$?
if [ $RET = 0 ] ; then
   echo "Script de bkp pra fita retornou sucesso !"
else
   echo "Script de bkp pra fita retornou erro."
fi
exit $RET
