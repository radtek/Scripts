Gera_cmd_bd_rman_cold ()
{
     ###########################################################################
     # Script que gera o arquivo de comandos do rman para cold backup do banco.
     # Recebe 5 parâtros:
     #   Primeiro: INCR = incremental
     #             CUMU = cumulative
     #             FULL = completo (default, se nao receber nada).
     #   Segundo.: níl do backup (default 0 (zero) se nao receber nada).
     #   Terceiro: Classe do NBU para realizacao do backup.
     #   Quarto..: Schedule do NBU para realizacao do backup.
     #   Quinto..: Variavel indicando se deve (Y) ou nao (N) ignorar as tablespace read only.
     ############################################################################

     TIPO_BKP=$1
     NIVEL=$2
     CLASSEBD=$3
     SCHEDBD=$4
     SKIP_READONLY=$5
     USE_CATALOG=$6
     # Atribui valores default para as variaveis quando nao foram setadas.
     if [ -z "$TIPO_BKP" ] ; then
        TIPO_BKP=FULL
     fi
     if [ -z "$NRO_CANAIS_BD" ] ; then
        NRO_CANAIS_BD=1
     fi
     if [ -z "$TIPO_CANAL_BD" ] ; then
        TIPO_CANAL_BD=disk
     fi
     if [ -z "$NIVEL" ] ; then
        NIVEL=0
     fi
     if [ -z "$SKIP_OFFLINE" ] ; then
        SKIP_OFFLINE=Y
     fi
     if [ -z "$SKIP_READONLY" ] ; then
        SKIP_READONLY=N
     fi
     if [ -z "$USE_CATALOG" ] ; then
        USE_CATALOG=N
     fi
     if [ -z "$ARQ_CMD_RMAN_BD" ] ; then
        ARQ_CMD_RMAN_BD=$ORACLE_BASE/oracledba/backup/rman_cmd_bd.rcv
     fi
     DATA=`date +'%Y%m%d'`
     TIME=`date +'%H%M%S'`
     FORMATO_BD=\'bkp_${TIPO_BKP}${NIVEL}_${DATA}_${TIME}_%d_s%s_p%p.rman\'
     FORMATO_CF=\'bkp_ctl_${DATA}_${TIME}_%d_s%s_p%p.rman\'
     # Inicio da geracao do arquivo de comandos do rman.
     {
        #  Mostra as variaveis de ambiente
        echo "##########################################################################"
        echo "# TIPO_BKP           = $TIPO_BKP                                          "
        echo "# CLASSEBD           = $CLASSEBD                                          "
        echo "# SCHEDBD            = $SCHEDBD                                           "
        echo "# NRO_CANAIS_BD      = $NRO_CANAIS_BD                                     "
        echo "# TIPO_CANAL_BD      = $TIPO_CANAL_BD                                     "
        echo "# LIMITE_TAM_CANAL   = $LIMITE_TAM_CANAL                                  "
        echo "# NIVEL              = $NIVEL                                             "
        echo "# SKIP_OFFLINE       = $SKIP_OFFLINE                                      "
        echo "# SKIP_READONLY      = $SKIP_READONLY                                     "
        echo "# FORMATO_BD         = $FORMATO_BD                                        "
        echo "# ARQ_CMD_RMAN_BD    = $ARQ_CMD_RMAN_BD                                   "
        echo "# JANELA_RETENTATIVA = $JANELA_RETENTATIVA                                "
        echo "# USE_CATALOG        = $USE_CATALOG                                       "
        echo "##########################################################################"
        if [ "$USE_CATALOG" = "Y" ] ; then
           echo "resync catalog;"
        fi
        echo "shutdown immediate;"
        echo "startup mount;"
        echo "run"
        echo "{"
        #
        #   # Aloca os canais do bkp
        #
        IND=0
        while [ $IND -lt $NRO_CANAIS_BD ] ;
        do
           IND=`expr $IND + 1 `
           echo "allocate channel c$IND type $TIPO_CANAL_BD;"
        done
        # Verifica se deve enviar alguma variavel para o software de backup.
        if [ ! -z "$CLASSEBD" ] ; then
           echo "send 'NB_ORA_CLASS=${CLASSEBD}';"
        fi
        if [ ! -z "$SCHEDBD" ] ; then
           echo "send 'NB_ORA_SCHED=${SCHEDBD}';"
        fi

        #Se for necessario setar um limite para o tamanho de arquivo gerado descomentar a proxima linha.
        if [ "$TIPO_BKP" = "INCR" ] ; then
           echo "backup incremental level $NIVEL database include current controlfile"
        else
           if [ "$TIPO_BKP" = "CUMU" ] ; then
              echo "backup incremental level $NIVEL cumulative database include current controlfile"
           else
              echo "backup full database include current controlfile"
           fi
        fi
        #
        # Apenas 1 datafile por backup set, pra agilizar o restore.
        #

        echo "filesperset 1"
        # Quando for preciso ignorar arquivos que estejam offline;
        if [ "$SKIP_OFFLINE" = "Y" -o "$SKIP_OFFLINE" = "y" -o "$SKIP_OFFLINE" = "S" -o "$SKIP_OFFLINE" = "s" ] ; then
           echo "skip offline"
        fi
        # Nãrealiza backup das tablespaces que estao read-only.
        if [ "$SKIP_READONLY" = "Y" -o "$SKIP_READONLY" = "y" -o "$SKIP_READONLY" = "S" -o "$SKIP_READONLY" = "s" ] ; then
           echo "skip readonly"
        fi
        # Realiza Backup apenas dos datafiles que nao foram pra backup na ultima janela de retentativa.
        # Por exemplo, se $JANELA_RETENTATIVA = 1 entao realiza backup somente dos datafiles que nao foram pra backup
        # no ultimo dia (nas ultimas 24 horas).
        if [ ! -z "$JANELA_RETENTATIVA" ] ; then
           echo "not backed up since time 'sysdate - $JANELA_RETENTATIVA'"
        fi

        if [ ! -z "$FORMATO_BD" ] ; then
           echo "format $FORMATO_BD;"
        else
           echo ";"
        fi

        echo "sql 'alter database backup controlfile to trace';"

        echo "Backup current controlfile format $FORMATO_CF;"

        echo "}"
        if [ "$USE_CATALOG" = "Y" ] ; then
           echo "resync catalog;"
        fi
        echo "alter database open;"
        echo "exit;"
     }  > $ARQ_CMD_RMAN_BD
}