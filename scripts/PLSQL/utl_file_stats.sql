  CREATE OR REPLACE PROCEDURE "STATREL"."PRC_LOAD_STATS_MONITOR" (p_dir in varchar2 default '/tmp')
is
  -----
  cursor monitor_cur is
    Select Schema_name, Process_name, Limit_Of_Days_without_load
      from stats_load_monitor_cfg
         where check_enabled = 'Y'
         Order by Schema_name, Process_name;
  ----
  lv_sql                varchar2(1000) := null;
  lv_general_status     integer      := 0;
  lv_file_name          varchar2(50) := Null;
  lv_file_descr         utl_file.file_type;
  lv_status             varchar2(10) := Null;
  lv_cur_date           date         := null;
  lv_max_data           date         := null;
  lv_error              varchar2(512):= null;
  LV_COUNT_OK           number       := null;
  lv_count_ER           number       := null;
  -------------------------------------------
  procedure prc_write_file (p_msg in varchar2) is
  Begin
    utl_file.put_line (lv_file_descr, p_msg );
    insert into stats_load_monitor_log (time_stamp, msg)
                                values (sysdate, p_msg);
    commit;
  exception
    when UTL_FILE.INVALID_FILEHANDLE then
       raise_application_error (-20004,'Erro INVALID_FILEHANDLE ao escrever no arquivo:'|| p_dir || lV_file_name);
    when UTL_FILE.INVALID_OPERATION then
       raise_application_error (-20005,'Erro INVALID_OPERATION (w) ao escrever no arquivo:'|| p_dir || lV_file_name);
    when UTL_FILE.WRITE_ERROR then
       raise_application_error (-20006,'Erro WRITE_ERROR (w) ao escrever no arquivo:'|| p_dir || lv_file_name);
  End prc_write_file;
  -------------------------------------------
Begin
  lv_cur_date := sysdate;
  --
  -- Abre o arquivo no s.o
  --
  lv_file_name := 'ora_load_stats_monitor.txt';
  begin
    lv_file_descr := utl_file.fopen (p_dir, lv_file_name, 'w');
  exception
    when UTL_FILE.INVALID_PATH then
       raise_application_error (-20001,'Erro INVALID_PATH ao abrir arquivo:'|| p_dir || lv_file_name);
    when UTL_FILE.INVALID_MODE then
       raise_application_error (-20002,'Erro INVALID_MODE (w) ao abrir arquivo:'|| p_dir || lv_file_name);
    when UTL_FILE.INVALID_OPERATION then
       raise_application_error (-20003,'Erro INVALID_OPERATION (w) ao abrir arquivo:'|| p_dir || lv_file_name);
  end;

  For M in Monitor_cur
  Loop
                ---
                --- Test the Last load status
                ---
         Begin
                lv_max_data := NULL;
                lv_sql := 'select Max(b.DT_STAT)'||
                          ' from '||M.schema_name||'.log_processo_cargas a, '||M.Schema_name||'.log_cargas b'||
                      ' where a.PROCESSO_CARGA_ID = b.PROCESSO_CARGA_ID '||
                                  ' and a.processo_carga = '||''''||M.Process_name||''''||
                          ' and status = ''OK'''||
                                  ' and b.dt_stat >= trunc(sysdate) - '||M.Limit_Of_Days_without_load;
                --dbms_output.put_line (lv_sql);
            Execute Immediate lv_sql    Into lv_max_data;
                --dbms_output.put_line ('Schema_name:'||M.Schema_name||' Process:'||M.Process_name||' Count ok:'||lv_count_Ok||' Count ER:'||lv_count_ER||' Last load date:'||to_char(lv_max_data,'YYYY-MM-DD'));
         Exception When others then
                lv_error := sqlerrm;
                lv_general_status := 1;
                prc_write_file ('Schema_name:'||M.Schema_name||' Process:'||M.Process_name||' ==> Error Getting last Load status ('||lv_error||').');
         End;
         ---
         if (lv_max_data is null) Then
            lv_general_status := 1;
            prc_write_file ('Schema_name:'||M.Schema_name||' Process:'||M.Process_name||' Error:'||
                            'Unable to get a success log record in the last '||M.Limit_Of_Days_without_load||' day(s).');
         else
            prc_write_file ('Schema_name:'||M.Schema_name||' Process:'||M.Process_name||
                                ' Verification is OK. Last Success load date:'||to_char(lv_max_data,'YYYY-MM-DD')||' Num Of limit days:'||M.Limit_Of_Days_without_load);
         end if;
  End Loop;
  ----
  ---- Grava Status Final
  ----
  if (lv_general_status = 0) then
     lv_status := 'SUCCESS';
  else
     lv_status := 'ERROR';
  end if;
  prc_write_file ('------------------------------------');
  prc_write_file ('CHECKDATE: '||to_char(lv_cur_date,'yyyy mm dd hh24 mi ss'));
  prc_write_file ('STATUS...: '||lv_status);
  --
  -- Fecha o arquivo
  --
  utl_file.fclose(lv_file_descr);
  --
End prc_load_stats_monitor;
