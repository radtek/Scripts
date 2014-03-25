rman target / catalog rman/rman@orarep trace=$ADM/logs/restore_movimentos_2002.log <<eof
run
{
allocate channel c1 type 'sbt_tape';
allocate channel c2 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
set newname for datafile '/o05/oradata/res_oraacct2/acct_mov_data_p1801.dbf' to '/b12/oradata/res_oraacct2/acct_mov_data_p1801.dbf';
set newname for datafile '/o05/oradata/res_oraacct2/acct_mov_data_p1802.dbf' to '/b12/oradata/res_oraacct2/acct_mov_data_p1802.dbf';

restore tablespace ACCT_MOV_DATA_P18; 
switch datafile all;
sql 'alter tablespace ACCT_MOV_DATA_P18 online';
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos.log"
fi
