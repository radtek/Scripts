## Esse script copia os archives p/ disco local
## Gediel, 07-jun-2005.
##
NLS_DATE_FORMAT="dd/mm/yyyy hh24:mi:ss"; export NLS_DATE_FORMAT
DIR_DEST=/home/oracle/bkp_local_archives
MAX_DIR_DEST_SIZE_KB=10000000
TAM_ATUAL_KB=`du -sk $DIR_DEST | cut -f 1`
DIAS=1
DATA=`date +'%Y%m%d'`
TIME=`date +'%H%M%S'`

echo "`date` -> Inicio do backup de archives para disco."
echo "Diretorio destino.....: $DIR_DEST"
echo "Tamanho limite(kb)....: $MAX_DIR_DEST_SIZE_KB"
echo "Espaco atual usado(kb): $TAM_ATUAL_KB"


if [ $TAM_ATUAL_KB -ge $MAX_DIR_DEST_SIZE_KB ] ; then
   echo "Tamanho limite ja atingido. Vai excluir os dois arquivos mais antigos..."
   
   LISTDEL=`ls -t $DIR_DEST/*.gz | tail -2`
   echo "---------------------------------------------------------------------" 
   echo "$DATA - $HORA :Removendo os $TOP arquivos mais antigos do diretorio:$DIR" 
   for L in $LISTDEL
   do
    echo "Removendo arquivo: $L" 
    rm $DIR/$L
   done
   echo "---------------------------------------------------------------------" 
   exit 1
fi 


# Se chegou ate aqui pode realizar o bkp.
$ORACLE_HOME/bin/rman target=/ catalog=rman/rman@orarep trace=$ADM/logs/bkp_local_archives.log append<<EOF
run
{
allocate channel c1 type disk;
sql 'alter system archive log current';
backup archivelog all not backed up
filesperset 20
format '$DIR_DEST/bkp_arc_%d_%s_%p_${DATA}_${TIME}.rman';
backup current controlfile format '$DIR_DEST/bkp_control_%d_%s_%p_${DATA}_${TIME}.rman';
release channel c1;
}
exit;
EOF
RET=$?


# Compacta os arquivos gerados pelo rman
gzip $DIR_DEST/*.rman

# Limpeza dos arquivos antigos

echo "---------------------------------------------------------------------" 
echo "`date` --> Limpando arquivos que nao foram alterados no(s) ultimo(s) $DIAS dia(s)." 
for D in $DIR_DEST
do
  echo "Processando limpeza do diretorio:" $D 
  find $D -ctime +$DIAS -exec echo Removendo {} \;
  find $D -mtime +$DIAS -exec echo Removendo {} \;
  find $D -ctime +$DIAS -exec rm {} \;
  find $D -mtime +$DIAS -exec rm {} \;
done
echo "---------------------------------------------------------------------"


if [ $RET = 0 ] ; then
   echo "`date` -> Final do backup de archives para disco com sucesso."
else
   echo "`date` -> Final do backup de archives para disco com erro."
   echo "Conferir log em $ADM/logs/bkp_local_archives.log"
fi
exit $RET


