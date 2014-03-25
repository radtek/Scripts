rman target / catalog rman/rman@orarep msglog=restore_movimentos2.log <<eof
run
{
set newname for datafile 192 to '/f02/oradata/res_oraacct2/acct_mov_data_p2301.dbf';
set newname for datafile 193 to '/o08/oradata/res_oraacct2/acct_mov_data_p2302.dbf';
set newname for datafile 194 to '/o08/oradata/res_oraacct2/acct_mov_data_p2303.dbf';
set newname for datafile 208 to '/o08/oradata/res_oraacct2/acct_mov_data_p2304.dbf';
allocate channel c1 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
restore tablespace ACCT_MOV_DATA_P23;
switch datafile all;
sql 'alter tablespace ACCT_MOV_DATA_P23 online';
}
exit;
eof
if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos.log"
fi
