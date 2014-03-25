NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
export NLS_DATE_FORMAT

date

rman target / catalog rman/rman@orarep trace=$ADM/logs/restore_untiltime.log <<eof
run
{
allocate channel c1 type 'sbt_tape';
set until time '20040826000000';
set newname for datafile 1 to '/o06/oradata/restore/system01.dbf';
set newname for datafile 2 to '/o06/oradata/restore/undotbs01.dbf';
set newname for datafile 389 to '/o06/oradata/restore/undotbs02.dbf';
set newname for datafile 227 to '/o06/oradata/restore/trr_resumodiario_user_data02_01.dbf';
set newname for datafile 226 to '/o06/oradata/restore/trr_resumodiario_user_data02_02.dbf';
set newname for datafile 357 to '/o06/oradata/restore/trr_resumodiario_user_data02_03.dbf';
restore tablespace system, undotbs01, trr_resumodiario_user_data02;
restore archivelog time between '20040825120000' and '20040826000000';
}
exit;
eof

if [ $? = 0 ] ; then
  echo "Restore finalizado com sucesso."
else
  echo "Restore finalizado com erro. Detalhes no log: restore_movimentos.log"
fi
date
