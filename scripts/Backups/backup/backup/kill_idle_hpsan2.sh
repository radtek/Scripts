#!/bin/sh
#
# Script que mata todas as sessoes do user HPSAN2 que estiverem inativas a mais de MAX_SEC segundos.
# Gediel, Dez/2006
#
MAX_SEC=600
. /home/oracle/.bash_profile
sqlplus /nolog <<eof
conn / as sysdba
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
set lines 200
set pages 0
set trimspool on
spool /tmp/kill_idle_hpsan2.tmp
select '-- Sid:'||a.sid||'  Osuser:'||a.osuser||' LT:'||a.logon_time||' LCET:'||a.last_call_et||chr(10)||
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;'||chr(10)||
       'host kill -9 '||b.spid
  from v\$Session a, v\$process b
 where a.username = 'HPSAN2'
   and a.machine  like 'irarema%'
   and a.paddr    = b.addr
   and a.last_call_et > ${MAX_SEC}
 Order by a.last_call_et desc;
spool off;
set echo on
@/tmp/kill_idle_hpsan2.tmp
exit;
eof

