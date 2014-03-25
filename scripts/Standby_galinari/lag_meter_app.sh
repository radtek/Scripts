#!/bin/bash
. /home/oracle/varejo.env
LAG_PATH=/home/oracle/ilegra/scripts/monitoracao_dg
LAG=`sqlplus -S / as sysdba << EOF
set head off feedback off
select
case
when M.lag_m >= 45 and H.lag_h <1 then '1' --P3
when H.lag_h = 1 then '2' --P5
when H.lag_h > 1 then '3'  --P6
else '0'  --OK
end "Status"
from
(select to_number(substr(value, instr(value,' ')+ 1,instr(substr(value, instr(value,' ')+ 1),':',-1,2) -1 ))  lag_h FROM V\\\$DATAGUARD_STATS WHERE NAME LIKE '%apply lag%' )H,
(select to_number(substr(value, instr(value,':',2,1)+1,instr(substr(value, instr(value,':',2,1)+1),':',2,1)-1)) lag_m FROM V\\\$DATAGUARD_STATS WHERE NAME LIKE '%apply lag%' )M;
exit;
EOF`

echo $LAG > $LAG_PATH/lag_meter_apply.res

### ORAREC

. /home/oracle/orarec.env
LAG_PATH=/home/oracle/ilegra/scripts/monitoracao_dg
LAG=`sqlplus -S / as sysdba << EOF
set head off feedback off
select
case
when M.lag_m >= 45 and H.lag_h <1 then '1' --P3
when H.lag_h = 1 then '2' --P5
when H.lag_h > 1 then '3'  --P6
else '0'  --OK
end "Status"
from
(select to_number(substr(value, instr(value,' ')+ 1,instr(substr(value, instr(value,' ')+ 1),':',-1,2) -1 ))  lag_h FROM V\\\$DATAGUARD_STATS WHERE NAME LIKE '%apply lag%' )H,
(select to_number(substr(value, instr(value,':',2,1)+1,instr(substr(value, instr(value,':',2,1)+1),':',2,1)-1)) lag_m FROM V\\\$DATAGUARD_STATS WHERE NAME LIKE '%apply lag%' )M;
exit;
EOF`

echo $LAG > $LAG_PATH/lag_meter_apply_orarec.res
