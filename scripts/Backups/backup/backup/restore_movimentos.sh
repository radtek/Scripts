#export NB_ORA_CLIENT=posados.terra.com.br
export NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
rman target / catalog RMAN/TRR_RMAN_123@oragc trace=$ADM/logs/restore_movimentos.log <<eof
SET PARALLELMEDIARESTORE OFF;
run
{
allocate channel c1 type 'sbt_tape';
allocate channel c2 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
allocate channel c5 type 'sbt_tape';
allocate channel c6 type 'sbt_tape';
#set newname for datafile 606 to '/d09/oradata/res_oraacct2/acct_mov_data_p36b_01.dbf';
#set newname for datafile 607 to '/d09/oradata/res_oraacct2/acct_mov_data_p36b_02.dbf';
#set newname for datafile 608 to '/d09/oradata/res_oraacct2/acct_mov_data_p36b_03.dbf';
#set newname for datafile 609 to '/d09/oradata/res_oraacct2/acct_mov_data_p36b_04.dbf';
#set newname for datafile 610 to '/d09/oradata/res_oraacct2/acct_mov_data_p36b_05.dbf';
#set newname for datafile 611 to '/d09/oradata/res_oraacct2/acct_mov_data_p36b_06.dbf';
restore tablespace ACCT_MOV_INDX_P80;
#switch datafile all;
sql 'alter tablespace  ACCT_MOV_INDX_P80  online';
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos.log"
fi
