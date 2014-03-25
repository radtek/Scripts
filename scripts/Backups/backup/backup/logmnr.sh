SEQ_INI=$1
SEQ_FIN=$2

echo "`date` => Inicio do processamento da sequencia $SEQ_INI ate a $SEQ_FIN"

sqlplus system/rqtyz7 <<eof
declare
  cursor c1 is
    select sequence#
    from v\$log_history
   where sequence# >= ${SEQ_INI} and sequence# <= ${SEQ_FIN}
   order by sequence#;
begin
  for r1 in c1 loop
     sys.dbms_logmnr.add_logfile('/o00/oradata/bkp/ORADB1_00000'||r1.sequence#||'.ARC',sys.dbms_logmnr.new);
     sys.dbms_logmnr.start_logmnr(options=>sys.dbms_logmnr.dict_from_online_catalog);
     insert into auditoria
      select timestamp,commit_timestamp,sql_redo,sql_undo,row_id,username,session_info
       from v\$logmnr_contents
      where seg_name = 'TRR_USR_ALMS'
        and sql_redo like '%AAACnGAAqAAAI0MAAE%';
     sys.dbms_logmnr.end_logmnr;
     insert into processed_logs values (r1.sequence#);
     commit;
  end loop;
end;
/
SPOOL off;
exit;
eof
echo "`date` => Final do processamento da sequencia $SEQ_INI ate a $SEQ_FIN"

