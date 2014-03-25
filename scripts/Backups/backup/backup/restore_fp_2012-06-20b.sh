export NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
rman target / catalog RMAN/TRR_RMAN_123@oragc trace=$ADM/logs/restore_fp_2012-06-20b.log <<eof
SET PARALLELMEDIARESTORE OFF;
run
{
allocate channel c1 type 'sbt_tape';
set newname for datafile '/d02/oradata/oraacct2/footprints_2.dbf' to '/d08/oradata/resfp/footprints_2.dbf';
restore datafile 896;
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_fp.log"
fi
