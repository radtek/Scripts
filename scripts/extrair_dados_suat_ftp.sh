########################################################################
#Gerar arquivo csv com reusltado de consulta e enviar para FTP
#Solicitação: Altair Borges Ticket: 5879
#27.07.2012
#
#
########################################################################


#variaveis oracle
ORACLE_SID=base06
ORACLE_BASE=/usr/local/oracle
ORACLE_TERM=xterm
ORACLE_HOME=/usr/local/oracle/product/10.2.0

# variaveis dos arquivos gerados
DIR_FILE=/dump01/backup/
FILE=suat_dump_`date +'%Y%m%d'`.gz
CSV1=Account_Contact_Information.csv
CSV2=Web_Provisioning.csv
CSV3=FTP_Login_Info.csv
FTPLOG=/tmp/ftp.log
DIR_LOG=$ADM/logs
LOG=${DIR_LOG}/suat_ftp_`date +'%Y-%m-%d'`.log
RETENCAO=7

# status arquivo
OK='SUCCESS'
NOK='NOK'

# status interno do script
ERRO=1
STATUS=0

#variaveis FTP
SERVERNAME=shell1c75.carrierzone.com
USERNAME=suat-ftp.com
PASSWORD=7y3us3w7

{
executar_consultas()
{
        # se uma der erro nao continua
        echo ------------------- executar_consultas -------------------
        echo data: `date`
        echo arquivos csv sao gerados em: $DIR_FILE

        #remover arquivos antigos
        echo removendo arquivos
        cd $DIR_FILE
        rm -f $CSV1
        rm -f $CSV2
        rm -f $CSV3
        cd -
        echo arquivos removidos
        echo executando `pwd`/suat_ftp_Account_Contact_Information.sql


        sqlplus -S / as sysdba @suat_ftp_Account_Contact_Information.sql
        if [ $? == 0 ]
        then
                echo finalizada com sucesso!!!
                echo executando `pwd`/suat_ftp_Web_Provisioning.sql
                sqlplus -S / as sysdba @suat_ftp_Web_Provisioning.sql

                if [ $? -eq 0 ]
                then
                        echo finalizada com sucesso!!!
                        sqlplus -S / as sysdba @suat_ftp_FTP_Login_Info.sql
                        if [ $? -eq 0 ]
                        then
                                echo finalizada com sucesso!!!
                        else
                                echo Erro na execucao da consulta!!!
                        fi
                else
                        STATUS=$ERRO
                        echo Erro na execucao da consulta!!!
                fi
        else
                STATUS=$ERRO
                echo Erro na execucao da consulta!!!
        fi
        echo ------------------- executar_consultas -------------------
}

gerar_arquivo()
{
        echo ------------------- gerar_arquivo -------------------
        echo data: `date`
        cd $DIR_FILE
        # remover arquivos já enviados maior de 7 dias
        echo removendo arquivos antigos
        pwd
        find -name "suat_dump_#.gz" -mtime +$RETENCAO -exec rm {} \;
        find -name "suat_ftp_#.log" -mtime +$RETENCAO -exec rm {} \;

        echo iniciando tar do arquivo

        tar cvfz $FILE $CSV1 $CSV2 $CSV3
        if [ $? -eq 0 ]
        then
                echo tar gerado com sucesso com sucesso !!!
                echo arquivo: `pwd`/$FILE
                cd -
        else
                echo Erro ao gerar arquivo tar
                echo espaço em disco:
                df -h

                STATUS=$ERRO
        fi
        echo ------------------- gerar_arquivo -------------------
}

gerar_log()
{
        echo ------------------- gerar_log -------------------
        echo data: `date`
        cd /tmp
        echo "-----------------------------------
CHECKDATE: `date +'%Y %m %d %k %M %S'`
STATUS...: $1
------------------------------------" > mon_suat_ftp.txt
        echo Status do log:
        cat mon_suat_ftp.txt
        echo
        cd -
        echo ------------------- gerar_log ---------------------------
}

enviar_ftp()
{
        echo ------------------- enviar_ftp ------------------------------
        echo data: `date`


lftp -u $USERNAME,$PASSWORD sftp://$SERVERNAME <<EOF
        put $DIR_FILE$FILE
        ls -l > $FTPLOG
        bye
EOF
        cd $DIR_FILE
        echo validar se ok envio
        v_ftp=`cat $FTPLOG | grep $FILE | wc -l`
        #cat $FTPLOG | grep $FILE | wc -l
        #echo $v_ftp
        if [ v_ftp == 0 ]
        then
                STATUS=$ERRO
                echo erro ao enviar arquivo para FTP
                echo arquivo log:
                cat $FTPLOG
        else
                echo Arquivo enviado com sucesso!
                echo arquivo log:
                cat $FTPLOG
        fi

        cd -

        echo ------------------- enviar_ftp -------------------
}

echo
echo
echo
echo -------------------------------------- Iniciando o processo `date` --------------------------------------

# so executa os proximos passos se nao ocorrer errors
# executa consultas no banco de dados e gera arquivos csv via spool
if [ $STATUS -eq 0 ]
then
        executar_consultas
        echo
fi


# gera arquivo tar comprimido
if [ $STATUS -eq 0 ]
then
        gerar_arquivo
        echo
fi

# envia arquivo tar para o ftp
if [ $STATUS -eq 0 ]
then
        enviar_ftp
        echo
fi

# atualiza o status para monitoramento
if [ $STATUS -eq 0 ]
then
        gerar_log $OK
else
        gerar_log $NOK
fi

echo -------------------------------------- Processo finalizado `date` --------------------------------------
} >> $LOG

exit
                        