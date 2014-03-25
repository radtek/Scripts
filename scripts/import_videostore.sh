########################################################################
# Script tem como objetivo realizar a carga de algumas tabelas do videostore@oraaws para o videostore@orasig
# Monitoração CORE:
#       -> agendado na crontab do oracle
#       -> Arquivo gerado /tmp/mon_import_videostore.txt
#       -> Quando finalizado contém string SUCCESS ou FAILED
# Monitoração BIT:
#       -> Mantém o status do processo na tabela BI_STG.TB_CONTROLE_CARGA
# Logs da execução:
#       -> Verificar arquivo do dia /usr/local/oracle/oracledba/logs/imp_videostore_<DATA>.log
# Novas tabelas:
#       -> Adicionar ao vetor TABLES na ultima posicao o nome da tabela qualificando com o owner, ex:
#               Nova tabela:
#                       teste4
#               Codigo atual:
#                       TABLES[1]=videostore.teste1
#                       TABLES[2]=videostore.teste2
#               Alterar para:
#                       TABLES[1]=videostore.teste1
#                       TABLES[2]=videostore.teste2
#                       TABLES[3]=videostore.teste4
#########################################################################


# Lista dinamica de tabelas do export
#TABLES[1]=videostore.teste1
#TABLES[2]=videostore.teste2
TABLES[1]=VIDEOSTORE.APPLICATIONS
TABLES[2]=VIDEOSTORE.PURCHASE_TYPE
TABLES[3]=VIDEOSTORE.VS_AUDIENCE
TABLES[4]=VIDEOSTORE.VS_AUDIENCE_TYPE
TABLES[5]=VIDEOSTORE.VS_DEVICE_TYPE
TABLES[6]=VIDEOSTORE.VS_ORDER_ITEMS
TABLES[7]=VIDEOSTORE.VS_ORDERS
TABLES[8]=VIDEOSTORE.VS_USER_CREDIT_TYPE
TABLES[9]=VIDEOSTORE.VS_USER_CREDITS
TABLES[10]=VIDEOSTORE.VS_USER_DEBITS
TABLES[11]=VIDEOSTORE.VS_USER_DOWNLOADS_HISTORY
TABLES[12]=VIDEOSTORE.VS_USER_DOWNLOADS
TABLES[13]=VIDEOSTORE.VS_USERS
TABLES[14]=VIDEOSTORE.MOVIES
TABLES[15]=VIDEOSTORE.SEASONS


#status do processo para controle da equipe do bit, procurar na tabela BI_STG.TB_CONTROLE_CARGA
PROC='PROC'
OK='OK'
NOK='NOK'

#status do processo para monitoramento do core
SUCCESS='SUCCESS'
FAILED='FAILED'

DIR_LOG=/usr/local/oracle/oracledba/logs
LOG=${DIR_LOG}/imp_videostore_`date +'%Y-%m-%d'`.log
export DIRDEST=/d01/oracle/oracledba/dmp

# carrega variaveis de ambiente ORACLE
. /home/oracle/.bash_profile

{

export_aws()
{


        ssh aws-db01-amazon "
        . /home/oracle/.bash_profile
        echo "Dir Dest:  ${DIRDEST}"
        cd ${DIRDEST}
        rm /tmp/videostore.log

        if [ -e parfile.par ]
        then
                rm parfile.par
        fi
        if [ -e videostore.dmp ]
        then
                rm videostore.dmp
        fi
        if [ -e videostore.log ]
        then
                rm videostore.log
        fi
        if [ -e videostore.dmp.gz ]
        then

                rm videostore.dmp.gz
        fi

        echo 'dumpfile=videostore.dmp' >> parfile.par
        echo 'directory=TMP_DIR' >> parfile.par
        echo 'logfile=videostore.log' >> parfile.par
        echo 'exclude=USER,CONSTRAINT,TRIGGER,GRANT,MATERIALIZED_VIEW_LOG' >> parfile.par
        echo 'tables=(${TABLES[*]})'  >> parfile.par

        export ORACLE_SID=oraaws
        expdp userid=\'/ as sysdba\' parfile=parfile.par
        gzip videostore.dmp
        if [ $? = 0 ] ; then
           echo 'Gzip finalizado com sucesso'
           cp videostore.log /tmp
        else
           echo 'Gzip finalizado com erro'
        fi

        exit
        "

        v_exp=`ssh aws-db01-amazon 'cat /tmp/videostore.log | grep "successfully completed" | wc -l'`
        #v_zip=`ssh aws-db01-amazon 'ls -l ${DIRDEST}/videostore.dmp.gz | wc -l'`
        retorno=$v_exp


        return $retorno
}

copy_dump()
{

        cd /tmp
        scp aws-db01-amazon:${DIRDEST}/videostore.dmp.gz .

        return $?
}

import_sig()
{
        cd /tmp
        if [ -e videostore.dmp ]
        then
                rm videostore.dmp
        fi
        gunzip videostore.dmp.gz

        if [ -e imp_videostore.log ]
        then
                rm imp_videostore.log
        fi

        export ORACLE_SID=orabatch02
        #impdp userid=\'/ as sysdba\' table_exists_action=truncate dumpfile=videostore.dmp logfile=imp_videostore.log directory=TMP_DIR
        impdp userid=videostore/videostore table_exists_action=truncate dumpfile=videostore.dmp logfile=imp_videostore.log directory=TMP_DIR

        v_log=`cat /tmp/imp_videostore.log | grep -v "ORA-39153" | grep "ORA-" | wc -l`
        return $v_log
}


gerar_log()
{
        cd /tmp
        echo "-----------------------------------
CHECKDATE: `date +'%Y %m %d %k %M %S'`
STATUS...: $1
------------------------------------" > mon_import_videostore.txt
}

update_status()
{
        export ORACLE_SID=orabatch02
        sqlplus -S / as sysdba << EOF
                MERGE INTO BI_STG.TB_CONTROLE_CARGA CC
                USING (SELECT 'BASE_VOD_D1' AS DS_ASSUNTO, TRUNC(SYSDATE-1) AS DT_REFERENCIA FROM DUAL) REF
                   ON (REF.DS_ASSUNTO=CC.DS_ASSUNTO
                   AND REF.DT_REFERENCIA=CC.DT_REFERENCIA)
                WHEN NOT MATCHED THEN INSERT(DS_ASSUNTO, DT_REFERENCIA, DS_STATUS, DT_TIMESTAMP)
                                         VALUES('BASE_VOD_D1', TRUNC(SYSDATE-1), '$1', SYSDATE)
                WHEN MATCHED THEN UPDATE SET DS_STATUS='$1', DT_TIMESTAMP=SYSDATE
                /
                COMMIT
                /
                exit
EOF


}


echo "---> Iniciando processo `date +'%Y-%m-%d %k:%M:%S'`"
echo "---> Atualizando status do processo para equipe do BIT"
update_status $PROC

echo '---> Iniciando export do oraaws'
export_aws

if [ $? -eq 1 ]
then
        echo
        echo 'Export finalizado com SUCCESSo! '

        echo '---> Iniciando copia do dump do oraaws para o orasig'
        copy_dump

        if [ $? -eq 0 ]
        then
                echo
                echo 'Copia do dump realizada com SUCCESSo!'

                echo
                echo '---> Iniciando import do dump no orasig'
                import_sig

                if [ $? -eq 0 ]
                then
                        echo
                        echo 'Import finalizado com SUCCESSo!'
                        echo '---> Gerando logs de SUCCESSo'
                        gerar_log $SUCCESS
                        echo "---> Atualizando status do processo para equipe do BIT"
                        update_status $OK


                        echo "---> Processo finalizado com SUCCESSo `date +'%Y-%m-%d %k:%M:%S'`"
                        echo '-----------------------------------------------------------------------'
                        exit 0
                else
                        echo
                        echo 'Import Finalizado com erros!'
                fi

        else
                echo
                echo 'Copia do dump com erros'
        fi
else
        echo
        echo 'Export finalizado com erros!'
fi

echo '---> Gerando logs de erro'
gerar_log $FAILED
echo "---> Atualizando status do processo para equipe do BIT"
update_status $NOK
echo "---> Processo finalizado com erros `date +'%Y-%m-%d %k:%M:%S'`"
echo '-----------------------------------------------------------------------'
exit 1

} >> $LOG 2>&1

exit
                      