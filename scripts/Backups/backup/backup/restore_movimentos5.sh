rman target / catalog rman/rman@orarep trace=$ADM/logs/restore_movimentos5.log <<eof
run
{
set newname for datafile '/b14/oradata/res_oraacct2/acct_mov_data_p54_1.dbf' to '/b04/oradata/res_oraacct2/acct_mov_data_p54_1.dbf'; 
set newname for datafile '/b14/oradata/res_oraacct2/acct_mov_data_p54_2.dbf' to '/b04/oradata/res_oraacct2/acct_mov_data_p54_2.dbf'; 
set newname for datafile '/b14/oradata/res_oraacct2/acct_mov_data_p54_3.dbf' to '/b04/oradata/res_oraacct2/acct_mov_data_p54_3.dbf'; 
set newname for datafile '/b14/oradata/res_oraacct2/acct_mov_data_p54_4.dbf' to '/b04/oradata/res_oraacct2/acct_mov_data_p54_4.dbf'; 
set newname for datafile '/b14/oradata/res_oraacct2/acct_mov_data_p54_5.dbf' to '/b04/oradata/res_oraacct2/acct_mov_data_p54_5.dbf'; 
set newname for datafile '/b14/oradata/res_oraacct2/acct_mov_data_p54_6.dbf' to '/b04/oradata/res_oraacct2/acct_mov_data_p54_6.dbf'; 
allocate channel c1 type 'sbt_tape';
allocate channel c2 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
restore tablespace ACCT_MOV_DATA_P53,ACCT_MOV_DATA_P54;
switch datafile all;
sql 'alter tablespace ACCT_MOV_DATA_P53 online';
sql 'alter tablespace ACCT_MOV_DATA_P54 online';
}
exit;
eof
if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos5.log"
fi
