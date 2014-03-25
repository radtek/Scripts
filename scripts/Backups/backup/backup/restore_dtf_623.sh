#export NB_ORA_CLIENT=posados.terra.com.br
export NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
rman target / catalog RMAN/TRR_RMAN_123@oragc trace=$ADM/logs/restore_dtf.log <<eof
SET PARALLELMEDIARESTORE OFF;
run
{
allocate channel c1 type 'sbt_tape';
set newname for datafile 623 to '/b17/oradata/res_oraacct2/acct_mov_data_p38b_06.dbf';
restore datafile 623;
switch datafile all;
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_dtf.log"
fi
