rman target / catalog rman/rman@orarep trace=$ADM/logs/restore_movimentos4.log <<eof
run
{
set newname for datafile '/o05/oradata/oraacct2/acct_mov_data_p301.dbf' to '/o05/oradata/res_oraacct2/acct_mov_data_p301.dbf';
set newname for datafile '/o05/oradata/oraacct2/acct_mov_data_p302.dbf' to '/o05/oradata/res_oraacct2/acct_mov_data_p302.dbf';
set newname for datafile '/o05/oradata/oraacct2/acct_mov_data_p401.dbf' to '/o05/oradata/res_oraacct2/acct_mov_data_p401.dbf';
set newname for datafile '/o05/oradata/oraacct2/acct_mov_data_p402.dbf' to '/o05/oradata/res_oraacct2/acct_mov_data_p402.dbf';
set newname for datafile '/o02/oradata/oraacct2/acct_mov_data_p501.dbf' to '/o05/oradata/res_oraacct2/acct_mov_data_p501.dbf';
set newname for datafile '/o02/oradata/oraacct2/acct_mov_data_p502.dbf' to '/o05/oradata/res_oraacct2/acct_mov_data_p502.dbf';
allocate channel c1 type 'sbt_tape';
allocate channel c2 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
restore tablespace ACCT_MOV_DATA_P1, ACCT_MOV_DATA_P2, ACCT_MOV_DATA_P3, ACCT_MOV_DATA_P4, ACCT_MOV_DATA_P5, ACCT_MOV_DATA_P6;
switch datafile all;
sql 'alter tablespace ACCT_MOV_DATA_P1 online';
sql 'alter tablespace ACCT_MOV_DATA_P2 online';
sql 'alter tablespace ACCT_MOV_DATA_P3 online';
sql 'alter tablespace ACCT_MOV_DATA_P4 online';
sql 'alter tablespace ACCT_MOV_DATA_P5 online';
sql 'alter tablespace ACCT_MOV_DATA_P6 online';
}
exit;
eof
if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos4.log"
fi
