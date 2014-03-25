rman target / catalog rman/rman@orarep msglog=restore_movimentos3.log <<eof
run
{
set newname for datafile  48 to '/o05/oradata/res_oraacct2/acct_mov_data_p1001.dbf';
set newname for datafile  62 to '/o05/oradata/res_oraacct2/acct_mov_data_p1002.dbf';
set newname for datafile  63 to '/o05/oradata/res_oraacct2/acct_mov_data_p1003.dbf';
allocate channel c1 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
restore tablespace ACCT_MOV_DATA_P10;
switch datafile all;
sql 'alter tablespace ACCT_MOV_DATA_P10 online';
}
exit;
eof
if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos3.log"
fi
