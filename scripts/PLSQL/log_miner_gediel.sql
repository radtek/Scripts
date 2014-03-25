-- menor e maior sequence
select min(SEQUENCE#), max(SEQUENCE#)
FROM gv$archived_log
WHERE trunc(COMPLETION_TIME) = trunc(sysdate -1)

-- espaço para archives
select sum((blocks * block_size) / 1024 / 1024) AS MB
FROM gv$archived_log
WHERE trunc(COMPLETION_TIME) = trunc(sysdate -1)




------- restore de archives
rman target=/ nocatalog trace=restore_arch.log <<eof
run {
set archivelog destination to '/dump01/restore/archives';
Allocate channel c1 type sbt_tape;
Allocate channel c2 type sbt_tape;
restore archivelog sequence between 352538 and 352876 thread = 1;
}
exit;
eof


--------------- log miner
sqlplus /nolog <<eof
conn / as sysdba
set echo on
set timing on
set time on


declare
  lv_caminho varchar2(500) := '/dump01/restore/archives/orausdw_';
  lv_format  varchar2(30)  := '_1_701377810.ARC';
begin
  for I in 352541..352876 loop
     sys.dbms_logmnr.add_logfile(lv_caminho||I||lv_format,sys.dbms_logmnr.new);
     sys.dbms_logmnr.start_logmnr(options=>sys.dbms_logmnr.dict_from_online_catalog);
     insert /*+ Append */ into system.logmnr_tk5442
     select *
      from v\$logmnr_contents
     Where Operation In ('DELETE')
       and seg_owner = 'BIPUB'
       AND table_name= 'TERRA_GATEWAY_LOG_SMS_MO';
     sys.dbms_logmnr.end_logmnr;
     Insert into system.logmnr_tk5442_log values (sysdate,I,'OK');
     commit;
  end loop;
end;
/

exit;
eof
