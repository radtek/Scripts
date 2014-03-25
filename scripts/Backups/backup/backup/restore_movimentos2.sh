#export NB_ORA_CLIENT=posados.terra.com.br
export NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
rman target / catalog rman/rman@orarep trace=$ADM/logs/restore_movimentos2.log <<eof
run
{
allocate channel c1 type 'sbt_tape';
allocate channel c2 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
allocate channel c5 type 'sbt_tape';
allocate channel c6 type 'sbt_tape';
restore tablespace ACCT_MOV_DATA_P54;
switch datafile all;
sql 'alter tablespace ACCT_MOV_DATA_P54 online';
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos.log"
fi
