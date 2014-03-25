#export NB_ORA_CLIENT=posados.terra.com.br
export NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
rman target / catalog RMAN/TRR_RMAN_123@oragc trace=$ADM/logs/restore_movimentos.log <<eof
run
{
allocate channel c1 type 'sbt_tape';
allocate channel c2 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
allocate channel c5 type 'sbt_tape';
allocate channel c6 type 'sbt_tape';
set newname for datafile '/o01/oradata/oraacct2/acct_mov_data_p42b_01.dbf' to '/archive01/oradata/oraacct2/acct_mov_data_p42b_01.dbf';
set newname for datafile '/o04/oradata/oraacct2/acct_mov_data_p42b_02.dbf' to '/archive01/oradata/oraacct2/acct_mov_data_p42b_02.dbf';
set newname for datafile '/o05/oradata/oraacct2/acct_mov_data_p42b_03.dbf' to '/archive01/oradata/oraacct2/acct_mov_data_p42b_03.dbf';
set newname for datafile '/o06/oradata/oraacct2/acct_mov_data_p42b_04.dbf' to '/archive01/oradata/oraacct2/acct_mov_data_p42b_04.dbf';
set newname for datafile '/o07/oradata/oraacct2/acct_mov_data_p42b_05.dbf' to '/archive01/oradata/oraacct2/acct_mov_data_p42b_05.dbf';
set newname for datafile '/o08/oradata/oraacct2/acct_mov_data_p42b_06.dbf' to '/archive01/oradata/oraacct2/acct_mov_data_p42b_06.dbf';
restore tablespace ACCT_MOV_DATA_P42B;
switch datafile all;
sql 'alter tablespace ACCT_MOV_DATA_P42B online';
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
./bkp_morto_tbl.sh bkp_oraacct2.conf "ACCT_MOV_DATA_P42B"
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos.log"
fi
