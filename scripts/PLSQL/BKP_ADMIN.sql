--exec bkp.bkp_admin.snap_create_req;


--financ
--basedb
--> setup hermes
 CREATE TABLE "BKP"."BKP$ASM_DISK_STAT"
  (    "DT_SNAP" DATE,
       "STARTUP_TIME" DATE,
       "PATH_ASM" VARCHAR2(20),
       "AVGRDTIME" NUMBER,
       "AVGWRTIME" NUMBER,
       "READS" NUMBER,
       "WRITES" NUMBER,
       "READ_TIME" NUMBER,
       "WRITE_TIME" NUMBER,
       "READ_ERRS" NUMBER,
       "WRITE_ERRS" NUMBER,
       "BYTES_READ" NUMBER,
       "BYTES_WRITTEN" NUMBER,
       "INSTANCE_NUMBER" VARCHAR2(12)
  ) 
 TABLESPACE "TOOLS" ;

CREATE INDEX "BKP"."IND_INST_DT_SNAP" ON "BKP"."BKP$ASM_DISK_STAT" ("INSTANCE_NUMBER", "DT_SNAP")
TABLESPACE "TOOLS" 
ONLINE
NOLOGGING;

--> setup novas
 CREATE TABLE "BKP"."BKP$ASM_DISK_GROUP"
  (    "DT_SNAP" DATE,
	"INSTANCE_NUMBER" NUMBER,
	name VARCHAR2(30), 
	total_mb NUMBER, 
	free_mb NUMBER
  ) 
 TABLESPACE "TOOLS" ;


CREATE INDEX "BKP"."IND_DG_DT_SNAP" ON "BKP"."BKP$ASM_DISK_GROUP" (INSTANCE_NUMBER, "DT_SNAP")
TABLESPACE "TOOLS" 
NOLOGGING;


  CREATE OR REPLACE PACKAGE "BKP"."BKP_ADMIN"
is
  --
  procedure prc_kill_user (p_sid    in number,
                           p_serial in number);
  --
  procedure snap_req;
  --
  procedure comp_req (p_dt_ini in date, p_dt_fim in date, P_detalhado in boolean default false);
  --
  procedure create_file_req (p_dir  in varchar2 default '/tmp/');
  --
  procedure snap_create_req;
end;
CREATE OR REPLACE PACKAGE BODY "BKP"."BKP_ADMIN" is
  Procedure snap_req is
    v_req_ini_shared   number := 0;
    v_req_ini_geral    number := 0;
    v_par_ini_geral    number := 0;
    v_par_ini_hard     number := 0;
    v_log_ini          number := 0;
    v_exe_ini          number := 0;
    v_rdo_ini          number := 0;
    v_cac_ini          number := 0;
    v_roll_ini         number := 0;
    v_comm_ini         number := 0;
    v_phyr_ini         number := 0;
    v_gets_ini         number := 0;
    v_enqueue_ini      number := 0;
    v_latch_free_ini   number := 0;
    v_db_file_scat_ini number := 0;
    v_db_file_seq_ini  number := 0;
    v_buffer_busy_ini  number := 0;
    v_sessions         number := 0;
    v_shared_conn      number := 0;
    v_dedicated_conn   number := 0;
    v_instance         number := 0;
    v_startup_time     date;
    v_sysdate          date;
	--- 10g centesimos, 11g segundos
	cursor c_asm is
      select substr(path, 6) "PATH",
             round((read_time)   / decode(reads, 0, 1, reads)) "AVGRDTIME",
             round((write_time) / decode(writes, 0, 1, writes)) "AVGWRTIME",
             READS,
             WRITES,
             READ_TIME,
             WRITE_TIME,
             READ_ERRS,
             WRITE_ERRS,
             BYTES_READ,
             BYTES_WRITTEN
        from v$asm_disk_stat;
    --
  begin
    --
    v_sysdate := sysdate;
    --
    select nvl(sum(requests), 0)
      into v_req_ini_shared
      from v$shared_server;
    select nvl(max(value), 0)
      into v_req_ini_geral
      from v$sysstat
     where name = 'user calls';
    select nvl(max(value), 0)
      into v_par_ini_geral
      from v$sysstat
     where name = 'parse count (total)';
    select nvl(max(value), 0)
      into v_par_ini_hard
      from v$sysstat
     where name = 'parse count (hard)';
    select nvl(max(value), 0)
      into v_log_ini
      from v$sysstat
     where name = 'logons cumulative';
    select nvl(max(value), 0)
      into v_exe_ini
      from v$sysstat
     where name = 'execute count';
    select nvl(max(value), 0)
      into v_rdo_ini
      from v$sysstat
     where name = 'redo size';
    select nvl(max(value), 0)
      into v_cac_ini
      from v$sysstat
     where name = 'session cursor cache hits';
    select nvl(max(value), 0)
      into v_roll_ini
      from v$sysstat
     where name = 'user rollbacks';
    select nvl(max(value), 0)
      into v_comm_ini
      from v$sysstat
     where name = 'user commits';
    select nvl(max(value), 0)
      into v_phyr_ini
      from v$sysstat
     where name = 'physical reads';
    select nvl(max(value), 0)
      into v_gets_ini
      from v$sysstat
     where name = 'session logical reads';
    select nvl(max(time_waited), 0)
      into v_enqueue_ini
      from v$system_event
     where (event = 'enqueue' or event like 'enq:%');
    select nvl(max(time_waited), 0)
      into v_latch_free_ini
      from v$system_event
     where event = 'latch free';
    select nvl(max(time_waited), 0)
      into v_db_file_scat_ini
      from v$system_event
     where event = 'db file scattered read';
    select nvl(max(time_waited), 0)
      into v_db_file_seq_ini
      from v$system_event
     where event = 'db file sequential read';
    select nvl(max(time_waited), 0)
      into v_buffer_busy_ini
      from v$system_event
     where event = 'buffer busy waits';
    select count(*) into v_sessions from v$session;
    select count(*)
      into v_dedicated_conn
      from v$session
     where server = 'DEDICATED';
    select count(*)
      into v_shared_conn
      from v$session
     where server <> 'DEDICATED';
    select STARTUP_TIME, instance_number
      into v_startup_time, v_instance
      from v$instance;
    --
    delete from bkp$req
     where dt_snap <= sysdate - 365
       and instance_number = v_instance;
    delete from bkp.bkp$asm_disk_stat
     where dt_snap <= sysdate - 365
       and instance_number = v_instance;
	 delete from "BKP"."BKP$ASM_DISK_GROUP"
     where dt_snap <= sysdate - 365
       and instance_number = v_instance;
    --
    insert into bkp$req
      (DT_SNAP,
       STARTUP_TIME,
       SHARED_REQ,
       USER_CALLS,
       PARSES,
       HARD_PARSES,
       LOGONS,
       EXECUTE_COUNT,
       REDO_SIZE,
       CACHED_CURSORS,
       USER_ROLLBACKS,
       USER_COMMITS,
       PHYSICAL_READS,
       LOGICAL_READS,
       ENQUEUE,
       LATCH_FREE,
       DB_FILE_SCAT,
       DB_FILE_SEQ,
       BUFFER_BUSY,
       sessions,
       dedicated_conn,
       shared_conn,
       INSTANCE_NUMBER)
    VALUES
      (v_sysdate,
       v_startup_time,
       v_req_ini_shared,
       v_req_ini_geral,
       v_par_ini_geral,
       v_par_ini_hard,
       v_log_ini,
       v_exe_ini,
       v_rdo_ini,
       v_cac_ini,
       v_roll_ini,
       v_comm_ini,
       v_phyr_ini,
       v_gets_ini,
       v_enqueue_ini,
       v_latch_free_ini,
       v_db_file_scat_ini,
       v_db_file_seq_ini,
       v_buffer_busy_ini,
       v_sessions,
       v_dedicated_conn,
       v_shared_conn,
       v_instance);
    --
    commit;
    --
    FOR i IN c_asm LOOP
      INSERT INTO bkp.bkp$asm_disk_stat
        (dt_snap,
         startup_time,
         path_asm,
         avgrdtime,
         avgwrtime,
         reads,
         writes,
         read_time,
         write_time,
         read_errs,
         write_errs,
         bytes_read,
         bytes_written,
         INSTANCE_NUMBER)
      VALUES
        (v_sysdate,
         v_startup_time,
         i.path,
         i.avgrdtime,
         i.avgwrtime,
         i.reads,
         i.writes,
         i.read_time,
         i.write_time,
         i.read_errs,
         i.write_errs,
         i.bytes_read,
         i.bytes_written,
         v_instance);
      COMMIT;
    END LOOP;
	INSERT INTO "BKP"."BKP$ASM_DISK_GROUP"("DT_SNAP" , "INSTANCE_NUMBER", "NAME" , "TOTAL_MB", "FREE_MB")
	SELECT v_sysdate, v_instance, NAME, TOTAL_MB, FREE_MB
	FROM V$ASM_DISKGROUP;
	COMMIT;
    --
  end snap_req;
  --####################################################################--
  procedure comp_req(p_dt_ini    in date,
                     p_dt_fim    in date,
                     P_detalhado in boolean default false) is
    ---
    v_dt_ini date := null;
    v_dt_fim date := null;
    v_existe number := null;
    ---
    v_aux1    date;
    v_aux2    date;
    v_cont    number := 0;
    v_periodo varchar2(100);
    ---
    cursor c1(dt_ini in date, dt_fim in date) is
      select b.SHARED_REQ - a.SHARED_REQ,
             b.USER_CALLS - a.USER_CALLS,
             b.PARSES - a.PARSES,
             b.HARD_PARSES - a.HARD_PARSES,
             b.LOGONS - a.LOGONS,
             b.EXECUTE_COUNT - a.EXECUTE_COUNT,
             b.redo_size - a.redo_size,
             b.sessions,
             round((b.dt_snap - a.dt_snap) * 24 * 60 * 60) Segundos
        from bkp$req a, bkp$req b
       where a.dt_snap = dt_ini
         and b.dt_snap = dt_fim
         and a.instance_number = b.instance_number
         and a.instance_number = (Select instance_number from v$instance);
    ---
    v_SHARED_REQ    bkp$req.SHARED_REQ%type;
    v_USER_CALLS    bkp$req.USER_CALLS%type;
    v_PARSES        bkp$req.PARSES%type;
    v_HARD_PARSES   bkp$req.HARD_PARSES%type;
    v_LOGONS        bkp$req.LOGONS%type;
    v_EXECUTE_COUNT bkp$req.EXECUTE_COUNT%type;
    v_REDO_SIZE     bkp$req.REDO_SIZE%type;
    v_segundos      number;
    --
    v_SHARED_REQ_s    bkp$req.SHARED_REQ%type;
    v_USER_CALLS_s    bkp$req.USER_CALLS%type;
    v_PARSES_s        bkp$req.PARSES%type;
    v_HARD_PARSES_s   bkp$req.HARD_PARSES%type;
    v_LOGONS_s        bkp$req.LOGONS%type;
    v_REDO_SIZE_s     bkp$req.REDO_SIZE%type;
    v_EXECUTE_COUNT_s bkp$req.EXECUTE_COUNT%type;
    ---
    v_SHARED_REQ_min      bkp$req.SHARED_REQ%type := 9999999999999999999;
    v_USER_CALLS_min      bkp$req.USER_CALLS%type := 9999999999999999999;
    v_PARSES_min          bkp$req.PARSES%type := 9999999999999999999;
    v_HARD_PARSES_min     bkp$req.HARD_PARSES%type := 9999999999999999999;
    v_LOGONS_min          bkp$req.LOGONS%type := 9999999999999999999;
    v_REDO_SIZE_MIN       bkp$req.REDO_SIZE%type := 9999999999999999999;
    v_EXECUTE_COUNT_min   bkp$req.EXECUTE_COUNT%type := 9999999999999999999;
    v_SHARED_REQ_min_p    varchar2(100);
    v_USER_CALLS_min_p    varchar2(100);
    v_PARSES_min_p        varchar2(100);
    v_HARD_PARSES_min_p   varchar2(100);
    v_LOGONS_min_p        varchar2(100);
    v_REDO_SIZE_MIN_p     varchar2(100);
    v_EXECUTE_COUNT_min_p varchar2(100);
    ---
    v_SHARED_REQ_max      bkp$req.SHARED_REQ%type := -9999999999999999999;
    v_USER_CALLS_max      bkp$req.USER_CALLS%type := -9999999999999999999;
    v_PARSES_max          bkp$req.PARSES%type := -9999999999999999999;
    v_HARD_PARSES_max     bkp$req.HARD_PARSES%type := -9999999999999999999;
    v_LOGONS_max          bkp$req.LOGONS%type := -9999999999999999999;
    v_EXECUTE_COUNT_max   bkp$req.EXECUTE_COUNT%type := -9999999999999999999;
    v_REDO_SIZE_MAX       bkp$req.REDO_SIZE%type := -9999999999999999999;
    v_SHARED_REQ_max_p    varchar2(100);
    v_USER_CALLS_max_p    varchar2(100);
    v_PARSES_max_p        varchar2(100);
    v_HARD_PARSES_max_p   varchar2(100);
    v_LOGONS_max_p        varchar2(100);
    v_REDO_SIZE_max_p     varchar2(100);
    v_EXECUTE_COUNT_max_p varchar2(100);
    ---
    v_SHARED_REQ_avg    bkp$req.SHARED_REQ%type := 0;
    v_USER_CALLS_avg    bkp$req.USER_CALLS%type := 0;
    v_PARSES_avg        bkp$req.PARSES%type := 0;
    v_HARD_PARSES_avg   bkp$req.HARD_PARSES%type := 0;
    v_LOGONS_avg        bkp$req.LOGONS%type := 0;
    v_EXECUTE_COUNT_avg bkp$req.EXECUTE_COUNT%type := 0;
    v_REDO_SIZE_avg     bkp$req.REDO_SIZE%type := 0;
    v_sessions          bkp$req.sessions%type := 0;
    ---
    function fnc_proximo(p_dt in date) return date is
      v_ret date;
    begin
      --
      select min(dt_snap)
        into v_ret
        from bkp$req
       where dt_snap > p_dt
         and instance_number = (Select instance_number from v$instance);
      --
      return(v_ret);
    end;
    --
  begin
    dbms_output.enable(1000000);
    if (p_dt_ini > p_dt_fim) then
      raise_application_error(-20003, 'Data inicial maior que data final.');
    end if;
    --
    -- Busca a menor e maior data de coleta dentro do intervalo passado.
    --
    select min(dt_snap), max(dt_snap)
      into v_dt_ini, v_dt_fim
      from bkp$req
     where dt_snap >= p_dt_ini
       and dt_snap <= p_dt_fim
       and instance_number = (Select instance_number from v$instance);
    if (v_dt_ini is null) or (v_dt_fim is null) then
      raise_application_error(-20001,
                              'N󿿣o 󿿩 poss󿿭vel determinar um intervalo de coleta com os par󿿢metros passados.');
    end if;
    --
    -- Verifica se as duas datas de coletas possuem o mesmo startup_time (startup da instance).
    --
    select max(1)
      into v_existe
      from bkp$req a, bkp$req b
     where a.dt_snap = v_dt_ini
       and b.dt_snap = v_dt_fim
       and a.startup_time = b.startup_time
       and a.instance_number = b.instance_number
       and a.instance_number = (Select instance_number from v$instance);
    if (v_existe is null) then
      raise_application_error(-20002,
                              'O intervalo especificado apresenta um shutdown/startup da instance.');
    end if;
    --
    dbms_output.put_line('------------------------------------------------');
    dbms_output.put_line('Carga no banco entre:' ||
                         to_char(v_dt_ini, 'dd/mm/yyyy hh24:mi:ss') ||
                         ' e ' ||
                         to_char(v_dt_fim, 'dd/mm/yyyy hh24:mi:ss') ||
                         chr(10) || chr(10));
    if (p_detalhado) then
      dbms_output.put_line('Per󿿭odo                                       User Calls   Req MTS         Parses     Hard Parses     Executes      Logons    Redo');
      dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------');
    end if;
    --
    v_aux1 := v_dt_ini;
    v_aux2 := fnc_proximo(v_aux1);
    --
    --
    loop
      --
      exit when v_aux2 is null or v_aux2 > v_dt_fim;
      --
      open c1(v_aux1, v_aux2);
      fetch c1
        into v_SHARED_REQ,
             v_USER_CALLS,
             v_PARSES,
             v_HARD_PARSES,
             v_LOGONS,
             v_EXECUTE_COUNT,
             v_REDO_SIZE,
             v_sessions,
             v_segundos;
      close c1;
      --
      v_cont            := v_cont + 1;
      v_periodo         := to_char(v_aux1, 'dd/mm/yyyy hh24:mi:ss') ||
                           ' - ' ||
                           to_char(v_aux2, 'dd/mm/yyyy hh24:mi:ss');
      v_SHARED_REQ_s    := round(v_SHARED_REQ / v_segundos, 2);
      v_USER_CALLS_s    := round(v_USER_CALLS / v_segundos, 2);
      v_PARSES_s        := round(v_PARSES / v_segundos, 2);
      v_HARD_PARSES_s   := round(v_HARD_PARSES / v_segundos, 2);
      v_LOGONS_s        := round(v_LOGONS / v_segundos, 2);
      v_EXECUTE_COUNT_s := round(v_EXECUTE_COUNT / v_segundos, 2);
      v_REDO_SIZE_s     := round(v_REDO_SIZE / v_segundos, 2);
      --
      if (v_SHARED_REQ_s < v_SHARED_REQ_min) then
        v_SHARED_REQ_min   := v_SHARED_REQ_s;
        v_SHARED_REQ_min_p := v_periodo;
      end if;
      if (v_SHARED_REQ_s > v_SHARED_REQ_max) then
        v_SHARED_REQ_max   := v_SHARED_REQ_s;
        v_SHARED_REQ_max_p := v_periodo;
      end if;
      v_SHARED_REQ_avg := v_SHARED_REQ_avg + v_SHARED_REQ_s;
      --
      if (v_USER_CALLS_s < v_USER_CALLS_min) then
        v_USER_CALLS_min   := v_USER_CALLS_s;
        v_USER_CALLS_min_p := v_periodo;
      end if;
      if (v_USER_CALLS_s > v_USER_CALLS_max) then
        v_USER_CALLS_max   := v_USER_CALLS_s;
        v_USER_CALLS_max_p := v_periodo;
      end if;
      v_USER_CALLS_avg := v_USER_CALLS_avg + v_USER_CALLS_s;
      --
      if (v_PARSES_s < v_PARSES_min) then
        v_PARSES_min   := v_PARSES_s;
        v_PARSES_min_p := v_periodo;
      end if;
      if (v_PARSES_s > v_PARSES_max) then
        v_PARSES_max   := v_PARSES_s;
        v_PARSES_max_p := v_periodo;
      end if;
      v_PARSES_avg := v_PARSES_avg + v_PARSES_s;
      --
      if (v_HARD_PARSES_s < v_HARD_PARSES_min) then
        v_HARD_PARSES_min   := v_HARD_PARSES_s;
        v_HARD_PARSES_min_p := v_periodo;
      end if;
      if (v_HARD_PARSES_s > v_HARD_PARSES_max) then
        v_HARD_PARSES_max   := v_HARD_PARSES_s;
        v_HARD_PARSES_max_p := v_periodo;
      end if;
      v_HARD_PARSES_avg := v_HARD_PARSES_avg + v_HARD_PARSES_s;
      --
      if (v_LOGONS_s < v_LOGONS_min) then
        v_LOGONS_min   := v_LOGONS_s;
        v_LOGONS_min_p := v_periodo;
      end if;
      if (v_LOGONS_s > v_LOGONS_max) then
        v_LOGONS_max   := v_LOGONS_s;
        v_LOGONS_max_p := v_periodo;
      end if;
      v_LOGONS_avg := v_LOGONS_avg + v_LOGONS_s;
      --
      if (v_EXECUTE_COUNT_s < v_EXECUTE_COUNT_min) then
        v_EXECUTE_COUNT_min   := v_EXECUTE_COUNT_s;
        v_EXECUTE_COUNT_min_p := v_periodo;
      end if;
      if (v_EXECUTE_COUNT_s > v_EXECUTE_COUNT_max) then
        v_EXECUTE_COUNT_max   := v_EXECUTE_COUNT_s;
        v_EXECUTE_COUNT_max_p := v_periodo;
      end if;
      v_EXECUTE_COUNT_avg := v_EXECUTE_COUNT_avg + v_EXECUTE_COUNT_s;
      --
      if (v_REDO_SIZE_s < v_REDO_SIZE_min) then
        v_REDO_SIZE_min   := v_REDO_SIZE_s;
        v_REDO_SIZE_min_p := v_periodo;
      end if;
      if (v_REDO_SIZE_s > v_REDO_SIZE_max) then
        v_REDO_SIZE_max   := v_REDO_SIZE_s;
        v_REDO_SIZE_max_p := v_periodo;
      end if;
      v_REDO_SIZE_avg := v_REDO_SIZE_avg + v_REDO_SIZE_s;
      --
      if (p_detalhado) then
        dbms_output.put_line(v_periodo || ':' ||
                             to_char(v_USER_CALLS, '999,999,999') || '  ' ||
                             to_char(v_SHARED_REQ, '999,999,999') || '  ' ||
                             to_char(v_PARSES, '999,999,999') || '  ' ||
                             to_char(v_HARD_PARSES, '999,999,999') || '  ' ||
                             to_char(v_EXECUTE_COUNT, '999,999,999') || '  ' ||
                             to_char(v_LOGONS, '999,999,999') || '  ' ||
                             to_char(v_REDO_SIZE, '999,999,999'));
        --
        dbms_output.put_line('_____________Por segundo ................:' ||
                             to_char(v_USER_CALLS_s, '999,999,999') || '  ' ||
                             to_char(v_SHARED_REQ_s, '999,999,999') || '  ' ||
                             to_char(v_PARSES_s, '999,999,999') || '  ' ||
                             to_char(v_HARD_PARSES_s, '999,999,999') || '  ' ||
                             to_char(v_EXECUTE_COUNT_s, '999,999,999') || '  ' ||
                             to_char(v_LOGONS_s, '999,999,999') || '  ' ||
                             to_char(v_REDO_SIZE_s, '999,999,999') ||
                             chr(10));
        --
      end if;
      --
      v_aux1 := v_aux2;
      v_aux2 := fnc_proximo(v_aux2);
      --
    end loop;
    v_SHARED_REQ_avg    := round(v_SHARED_REQ_avg / v_cont, 2);
    v_USER_CALLS_avg    := round(v_USER_CALLS_avg / v_cont, 2);
    v_PARSES_avg        := round(v_PARSES_avg / v_cont, 2);
    v_HARD_PARSES_avg   := round(v_HARD_PARSES_avg / v_cont, 2);
    v_LOGONS_avg        := round(v_LOGONS_avg / v_cont, 2);
    v_EXECUTE_COUNT_avg := round(v_EXECUTE_COUNT_avg / v_cont, 2);
    v_REDO_SIZE_avg     := round(v_REDO_SIZE_avg / v_cont, 2);
    dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------');
    dbms_output.put_line('Sum󿿡rio (por segundo):' || chr(10));
    dbms_output.put_line('User Calls.');
    dbms_output.put_line('MIN:' || v_USER_CALLS_min_p || ' => ' ||
                         v_USER_CALLS_min);
    dbms_output.put_line('MAX:' || v_USER_CALLS_max_p || ' => ' ||
                         v_USER_CALLS_max);
    dbms_output.put_line('AVG:' || v_USER_CALLS_avg || chr(10));
    dbms_output.put_line('Req MTS.');
    dbms_output.put_line('MIN:' || v_SHARED_REQ_min_p || ' => ' ||
                         v_SHARED_REQ_min);
    dbms_output.put_line('MAX:' || v_SHARED_REQ_max_p || ' => ' ||
                         v_SHARED_REQ_max);
    dbms_output.put_line('AVG:' || v_SHARED_REQ_avg || chr(10));
    dbms_output.put_line('Parses.');
    dbms_output.put_line('MIN:' || v_PARSES_min_p || ' => ' ||
                         v_PARSES_min);
    dbms_output.put_line('MAX:' || v_PARSES_max_p || ' => ' ||
                         v_PARSES_max);
    dbms_output.put_line('AVG:' || v_PARSES_avg || chr(10));
    dbms_output.put_line('Hard Parses.');
    dbms_output.put_line('MIN:' || v_HARD_PARSES_min_p || ' => ' ||
                         v_HARD_PARSES_min);
    dbms_output.put_line('MAX:' || v_HARD_PARSES_max_p || ' => ' ||
                         v_HARD_PARSES_max);
    dbms_output.put_line('AVG:' || v_HARD_PARSES_avg || chr(10));
    dbms_output.put_line('Executes.');
    dbms_output.put_line('MIN:' || v_EXECUTE_COUNT_min_p || ' => ' ||
                         v_EXECUTE_COUNT_min);
    dbms_output.put_line('MAX:' || v_EXECUTE_COUNT_max_p || ' => ' ||
                         v_EXECUTE_COUNT_max);
    dbms_output.put_line('AVG:' || v_EXECUTE_COUNT_avg || chr(10));
    dbms_output.put_line('Logons.');
    dbms_output.put_line('MIN:' || v_LOGONS_min_p || ' => ' ||
                         v_LOGONS_min);
    dbms_output.put_line('MAX:' || v_LOGONS_max_p || ' => ' ||
                         v_LOGONS_max);
    dbms_output.put_line('AVG:' || v_LOGONS_avg || chr(10));
    dbms_output.put_line('Redo.');
    dbms_output.put_line('MIN:' || v_REDO_SIZE_min_p || ' => ' ||
                         round(v_REDO_SIZE_min / 1024) || ' Kb');
    dbms_output.put_line('MAX:' || v_REDO_SIZE_max_p || ' => ' ||
                         round(v_REDO_SIZE_max / 1024) || ' Kb');
    dbms_output.put_line('AVG:' || round(v_REDO_SIZE_avg / 1024) || ' Kb' ||
                         chr(10));
    dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------');
  end comp_req;
  --####################################################################--
  procedure create_file_req(p_dir in varchar2 default '/tmp/') is
    --
    vl_user_calls     number := 0;
    vl_transaction    number := 0;
    vl_redo_size      number := 0;
    vl_parse          number := 0;
    vl_parse_hard     number := 0;
    vl_logons         number := 0;
    vl_physical_reads number := 0;
    vl_logical_reads  number := 0;
    vl_user_commits   number := 0;
    vl_user_rollbacks number := 0;
    vl_buffer_hit     number := 0;
     vl_enqueue        number := 0;
    vl_latch_free     number := 0;
    vl_db_file_scat   number := 0;
    vl_db_file_seq    number := 0;
    vl_buffer_busy    number := 0;
    vl_sessions       number := 0;
    vl_dedicated_conn number := 0;
    vl_shared_conn    number := 0;
    vl_segundos       number := 0;
    vl_instance       varchar2(100) := null;
    vl_file_name      varchar2(200) := 'mon_';
    vl_file_descr     utl_file.file_type;
    -- snap
    vl_snap_ini  date;
    vl_start_ini date;
    vl_snap_fim  date;
    vl_start_fim date;
    --
	-- snap	asm
    vl_snap_asm_ini  date;
    vl_start_asm_ini date;
    vl_snap_asm_fim  date;
    vl_start_asm_fim date;
    --
	-- oracle version
	vl_oracle_version number;
    -- Pega os dois 󿿺ltimos snaps
    --
    cursor snap_cur is
      select *
        from (select dt_snap, startup_time
                from bkp$req
               where instance_number =
                     (Select instance_number from v$instance)
               order by dt_snap desc)
       where rownum <= 2;
    --
    -- Pega a diferenca dos dados
    --
    cursor diff_cur(dt_ini in date, dt_fim in date) is
      select b.USER_CALLS - a.USER_CALLS,
             b.PARSES - a.PARSES,
             b.HARD_PARSES - a.HARD_PARSES,
             b.LOGONS - a.LOGONS,
             b.redo_size - a.redo_size,
             b.user_commits - a.user_commits,
             b.user_rollbacks - a.user_rollbacks,
             b.physical_reads - a.physical_reads,
             b.logical_reads - a.logical_reads,
             (b.enqueue - a.enqueue) / 100,
             (b.latch_free - a.latch_free) / 100,
             (b.db_file_scat - a.db_file_scat) / 100,
             (b.db_file_seq - a.db_file_seq) / 100,
             (b.buffer_busy - a.buffer_busy) / 100,
             b.sessions,
             b.dedicated_conn,
             b.shared_conn,
             round((b.dt_snap - a.dt_snap) * 24 * 60 * 60) Segundos
        from bkp$req a, bkp$req b
       where a.dt_snap = dt_ini
         and b.dt_snap = dt_fim
         and a.instance_number = b.instance_number
         and a.instance_number = (Select instance_number from v$instance);
	cursor snap_cur_asm is
      select *
        from (select distinct dt_snap, startup_time
                from bkp.bkp$asm_disk_stat
               where instance_number =
                     (Select instance_number from v$instance)
               order by dt_snap desc)
       where rownum <= 2
	   order by dt_snap desc;
  begin
    --- get oracle version
	select
		case when version like '11%' then 11
		when version like '10%' then 10
		else 0 end
	into vl_oracle_version
	FROM V$INSTANCE;
    -- snap interval
    begin
      OPEN snap_cur;
      fetch snap_cur
        into vl_snap_fim, vl_start_fim;
      fetch snap_cur
        into vl_snap_ini, vl_start_ini;
      close snap_cur;
    exception
      when others then
        null;
    end;
	-- snap asm	interval
	begin
      OPEN snap_cur_asm;
      fetch snap_cur_asm
        into vl_snap_asm_fim, vl_start_asm_fim;
      fetch snap_cur_asm
        into vl_snap_asm_ini, vl_start_asm_ini;
      close snap_cur_asm;
    exception
      when others then
        null;
    end;
    --
    if (vl_start_fim = vl_start_ini) and (vl_snap_fim > vl_snap_ini) then
      --
      open diff_cur(vl_snap_ini, vl_snap_fim);
      fetch diff_cur
        into vl_user_calls,
             vl_parse,
             vl_parse_hard,
             vl_logons,
             vl_redo_size,
             vl_user_commits,
             vl_user_rollbacks,
             vl_physical_reads,
             vl_logical_reads,
             vl_enqueue,
             vl_latch_free,
             vl_db_file_scat,
             vl_db_file_seq,
             vl_buffer_busy,
             vl_sessions,
             vl_dedicated_conn,
             vl_shared_conn,
             vl_segundos;
      close diff_cur;
      --
      vl_transaction := vl_user_commits + vl_user_rollbacks;
      vl_buffer_hit  := round(100 *
                              (1 - vl_physical_reads / vl_logical_reads),
                              2);
      --
      -- Devolve o calculo por segundo.
      --
      vl_user_calls  := round(vl_user_calls / vl_segundos, 2);
      vl_parse       := round(vl_parse / vl_segundos, 2);
      vl_parse_hard  := round(vl_parse_hard / vl_segundos, 2);
      vl_logons      := round(vl_logons / vl_segundos, 2);
      vl_redo_size   := round((vl_redo_size / 1024) / vl_segundos, 2);
      vl_transaction := round(vl_transaction / vl_segundos, 2);
      --
    end if;
    --
    -- Pega o nome da instance para montas o nome do arquivo
    --
    select instance_name into vl_instance from v$instance;
    --
    vl_file_name := vl_file_name || vl_instance || '.txt';
    --
    -- Abre o arquivo no s.o
    --
    begin
      vl_file_descr := utl_file.fopen(p_dir, vl_file_name, 'w');
    exception
      when UTL_FILE.INVALID_PATH then
        raise_application_error(-20001,
                                'Erro INVALID_PATH ao abrir arquivo:' ||
                                p_dir || vl_file_name);
      when UTL_FILE.INVALID_MODE then
        raise_application_error(-20002,
                                'Erro INVALID_MODE (w) ao abrir arquivo:' ||
                                p_dir || vl_file_name);
      when UTL_FILE.INVALID_OPERATION then
        raise_application_error(-20003,
                                'Erro INVALID_OPERATION (w) ao abrir arquivo:' ||
                                p_dir || vl_file_name);
    end;
    --
    -- Escreve no arquivo
    --
    begin
      utl_file.put_line(vl_file_descr, 'USER CALLS:' || vl_user_calls);
      utl_file.put_line(vl_file_descr, 'TRANSACTIONS:' || vl_transaction);
      utl_file.put_line(vl_file_descr, 'REDO SIZE:' || vl_redo_size);
      utl_file.put_line(vl_file_descr, 'PARSE:' || vl_parse);
      utl_file.put_line(vl_file_descr, 'HARD PARSE:' || vl_parse_hard);
      utl_file.put_line(vl_file_descr, 'LOGONS:' || vl_logons);
      utl_file.put_line(vl_file_descr, 'BUFFER HIT:' || vl_buffer_hit);
      utl_file.put_line(vl_file_descr, 'ENQUEUE:' || vl_enqueue);
      utl_file.put_line(vl_file_descr, 'LATCH FREE:' || vl_latch_free);
      utl_file.put_line(vl_file_descr,
                        'DB FILE SCATTERED READ:' || vl_db_file_scat);
      utl_file.put_line(vl_file_descr,
                        'DB FILE SEQUENTIAL READ:' || vl_db_file_seq);
      utl_file.put_line(vl_file_descr,
                        'BUFFER BUSY WAITS:' || vl_buffer_busy);
      utl_file.put_line(vl_file_descr,
                        'LOGICAL READS:' || vl_logical_reads);
      utl_file.put_line(vl_file_descr, 'SESSIONS:' || vl_sessions);
      utl_file.put_line(vl_file_descr,
                        'DEDICATED_CONN:' || vl_dedicated_conn);
      utl_file.put_line(vl_file_descr, 'SHARED_CONN:' || vl_shared_conn);
      ---
	-- snap asm disk stat diff
	if (vl_start_asm_fim = vl_start_asm_ini) and (vl_snap_asm_fim > vl_snap_asm_ini) then
		  for i in (select  -- 11g lista em segundos e 10g em centesimos
						  'AVGRDTIMEMS_' || a.PATH_ASM || ':' ||
						   to_char(round(((b.read_time  - a.read_time ) * case when vl_oracle_version=10 then 10 when vl_oracle_version=11 then 1000 else 1 end) / decode(b.reads  - a.reads , 0, 1, b.reads  - a.reads))) as AVGRDTIMEMS,
						   'AVGWRTIMEMS_' || a.PATH_ASM || ':' ||
						   to_char(round(((b.write_time - a.write_time) * case when vl_oracle_version=10 then 10 when vl_oracle_version=11 then 1000 else 1 end) / decode(b.writes - a.writes, 0, 1, b.writes - a.writes))) as AVGWRTIMEMS,
						   'READS_' || a.PATH_ASM || ':' ||
						   to_char(b.READS - a.READS) as READS_DELTA,
						   'WRITES_' || a.PATH_ASM || ':' ||
						   to_char(b.WRITES - a.WRITES) as WRITES_DELTA
					from bkp.bkp$asm_disk_stat a,
						 bkp.bkp$asm_disk_stat b
					where a.instance_number = (Select instance_number from v$instance)
					  and a.DT_SNAP = vl_snap_asm_ini
					  and b.DT_SNAP = vl_snap_asm_fim
					  and a.PATH_ASM = b.PATH_ASM
					  and b.instance_number = a.instance_number
					  and a.STARTUP_TIME = b.STARTUP_TIME
					) loop
			-- faz a escrita no arquivo
			utl_file.put_line(vl_file_descr, i.AVGRDTIMEMS);
			utl_file.put_line(vl_file_descr, i.AVGWRTIMEMS);
			utl_file.put_line(vl_file_descr, i.READS_DELTA);
			utl_file.put_line(vl_file_descr, i.WRITES_DELTA);
		 end loop;
	end if;
	for i in (  select 'FREESPACE_' || NAME || ':' ||
					   to_char(free_mb) as "AVG"
				from "BKP"."BKP$ASM_DISK_GROUP"
				where (DT_SNAP, instance_number) = (select max(DT_SNAP), INSTANCE_NUMBER from "BKP"."BKP$ASM_DISK_GROUP" where instance_number = (Select instance_number from v$instance) group by instance_number)
				union
				select 'TOTALSPACE_' || NAME || ':' ||
					   to_char(total_mb) as "AVG"
				from "BKP"."BKP$ASM_DISK_GROUP"
				where (DT_SNAP, instance_number) = (select max(DT_SNAP), INSTANCE_NUMBER from "BKP"."BKP$ASM_DISK_GROUP" where instance_number = (Select instance_number from v$instance) group by instance_number)
					   ) loop
		utl_file.put_line(vl_file_descr, i.AVG);
	  end loop;
	  dbms_output.put_line('final do procedimento');
      ---
    exception
      when UTL_FILE.INVALID_FILEHANDLE then
        raise_application_error(-20004,
                                'Erro INVALID_FILEHANDLE ao escrever no arquivo:' ||
                                p_dir || vl_file_name);
      when UTL_FILE.INVALID_OPERATION then
        raise_application_error(-20005,
                                'Erro INVALID_OPERATION (w) ao escrever no arquivo:' ||
                                p_dir || vl_file_name);
      when UTL_FILE.WRITE_ERROR then
        raise_application_error(-20006,
                                'Erro WRITE_ERROR (w) ao escrever no arquivo:' ||
                                p_dir || vl_file_name);
    end;
    --
    -- Fecha o arquivo
    --
    utl_file.fclose(vl_file_descr);
  end create_file_req;
  --####################################################################--
  procedure snap_create_req is
  begin
    snap_req;
    create_file_req;
  end snap_create_req;
  --####################################################################--
  procedure prc_kill_user(p_sid in number, p_serial in number) is
    lv_log_user    varchar2(30);
    lv_killed_user varchar2(30);
  begin
    -- Get de current user
    select user into lv_log_user from dual;
    -- Get the user to kill
    select max(username)
      into lv_killed_user
      from v$session
     where sid = p_sid
       and serial# = p_serial;
    If (lv_killed_user is null) then
      raise_application_error(-20001,
                              'Cannot get user with sid:' || p_sid ||
                              ' and serial#: ' || p_serial);
    elsif (lv_killed_user <> lv_log_user) then
      raise_application_error(-20002,
                              'You can only kill users with the same username that you have.');
    else
      execute immediate ('alter system kill session ' || '''' || p_sid || ',' ||
                        p_serial || '''');
    end if;
  end;
--####################################################################--
end bkp_admin;
