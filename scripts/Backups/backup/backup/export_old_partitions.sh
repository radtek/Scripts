####################################################################################################################
# Script que realiza export da particao mais antiga e abre chamado para realizacao do morto do dmp gerado.
# O script recebe 2 parametros:
# 1) Owner
# 2) Nome da tabela
# Ele verifica na system.particao_tab_config no campo NRO_PARTICOES_READ_ONLY. Se a tabela tiver mais
# Particoes Read only que esse nro ele exporta essas particoes.
####################################################################################################################
. /home/oracle/.bash_profile

DATA_ATUAL=`date +'%Y%m%d%H%M%S'`
WORK_DIR=$ORACLE_BASE/oracledba
DIR_SAIDA="${WORK_DIR}/logs"
ARQ_SAIDA="lista_tbs_export.${DATA_ATUAL}"
BDUSR=BKP
BDPAS=BKPORAACCT2
DIR_DEST_DMPS=/home/oracle/bkp/dmp
RET_PROC=0
OWNER=$1
TABLE=$2

if [ ! $# = 2 ] ; then
  echo " "
  echo "Deve ser passado 2 parametros:"
  echo "1o) Owner da tabela no banco."
  echo "2o) Nome da tabela no banco."
  echo " "
  exit 1
fi

echo "`date ` => Inicio do Script. OWNER:$OWNER TABLE:$TABLE"




# Chama procedure para gerar a lista de tabelas/particoes que serao exportadas.
sqlplus /nolog <<eof
conn / as sysdba
begin
  system.pkg_sgp.prc_gera_lista_tbs_of(
       P_DIRETORIO_SAIDA => '${DIR_SAIDA}',
       P_ARQUIVO_SAIDA   => '${ARQ_SAIDA}',
       P_OWNER           => upper('${OWNER}'),
       P_TABLE_NAME      => upper('${TABLE}'),
       P_LISTA_PARTICOES => TRUE);
end;
/
exit;
eof
if [ ! $? = 0 ] ; then
   echo "`date ` => Erro encontrado na geracao da lista de particoes.."
   exit 2
fi

echo "Antes do Loop das Particoes"

# Pega a particao que foi gerada e realiza o export e abre chamado solicitando bkp morto do dmp.
echo "file:${DIR_SAIDA}/${ARQ_SAIDA}"
if [ -f  ${DIR_SAIDA}/${ARQ_SAIDA} ] ; then
  echo "Antes do List"
  LIST_TBS=`cat ${DIR_SAIDA}/${ARQ_SAIDA}`
  echo "Lista:$LIST_TBS"
  for L in ${LIST_TBS}
  do
        echo "`date ` => Processando Particao $L.."
        echo "`date ` => Realiza bkp via export:"
        exp $BDUSR/$BDPAS file=$DIR_DEST_DMPS/${OWNER}_${TABLE}_${L}.dmp log=$DIR_SAIDA/exp_${OWNER}_${TABLE}_${L}.log \
        tables=${OWNER}.${TABLE}:${L} feedback=10000000 direct=y rows=y
        if [ ! $? = 0 ] ; then
                echo "`date ` => Erro encontrado no export."
                exit 3
        fi

        echo "`date ` => Compacta o arquivo gerado"
        gzip -f $DIR_DEST_DMPS/${OWNER}_${TABLE}_${L}.dmp
        if [ ! $? = 0 ] ; then
                echo "`date ` => Erro encontrado no gzip do dmp."
                exit 4
        fi

        #echo "`date ` => Manda email para abrir chamado solicitando o morto do dmp gerado."
        #$WORK_DIR/backup/abre_chamado_morto_dmps.sh $L $DIR_DEST_DMPS/${OWNER}_${TABLE}_${L}.dmp.gz ${OWNER} ${TABLE}
        #if [ ! $? = 0 ] ; then
        #        echo "`date ` => Erro encontrado na abertura do chamado."
        #        exit 5
        #fi
        ######
        echo "`date` => Copia o arquivo pra fita e remove do disco"
        mkdir $DIR_DEST_DMPS/enviando_pra_fita_${DATA_ATUAL}
        mv $DIR_DEST_DMPS/${OWNER}_${TABLE}_${L}.dmp.gz $DIR_DEST_DMPS/enviando_pra_fita_${DATA_ATUAL}/
        $WORK_DIR/backup/BkpToNetbackup.sh $DIR_DEST_DMPS/enviando_pra_fita_${DATA_ATUAL} "ORAEXP ${OWNER} ${TABLE}-${L}"
        if [ ! $? = 0 ] ; then
            echo "`date ` => Erro encontrado no envio do bkp pra fita"
            exit 5
        fi
        ######
  done
else
  echo "`date ` => Não foi gerado arquivo com a particao a ser exportada."
  exit 6
fi

echo "`date ` => Final com sucesso."
exit 0

