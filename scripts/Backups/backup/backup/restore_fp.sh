export NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
rman target / catalog RMAN/TRR_RMAN_123@oragc trace=$ADM/logs/restore_fp.log <<eof
SET PARALLELMEDIARESTORE OFF;
run
{
allocate channel c1 type 'sbt_tape';
allocate channel c2 type 'sbt_tape';
allocate channel c3 type 'sbt_tape';
allocate channel c4 type 'sbt_tape';
allocate channel c5 type 'sbt_tape';
allocate channel c6 type 'sbt_tape';
set newname for datafile '/d09/oradata/oraacct2/undotbs01.dbf'  to '/d08/oradata/resfp/undotbs01.dbf';
set newname for datafile '/d09/oradata/oraacct2/undotbs02.dbf'  to '/d08/oradata/resfp/undotbs02.dbf';        
set newname for datafile '/d09/oradata/oraacct2/undotbs03.dbf'  to '/d08/oradata/resfp/undotbs03.dbf';       
set newname for datafile '/d09/oradata/oraacct2/undotbs04.dbf'  to '/d08/oradata/resfp/undotbs04.dbf';        
set newname for datafile '/d09/oradata/oraacct2/undotbs05.dbf'  to '/d08/oradata/resfp/undotbs05.dbf';        
set newname for datafile '/d09/oradata/oraacct2/system01.dbf'   to '/d08/oradata/resfp/system01.dbf'; 
set newname for datafile '/d03/oradata/oraacct2/FOOTPRINTS.dbf' to '/d08/oradata/resfp/FOOTPRINTS.dbf';
restore tablespace system,UNDOTBS01,FOOTPRINTS;
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_fp.log"
fi
