
accept dt1_ini prompt          'Start Time (1) (dd/mm/yyyy hh24:mi:ss):'
accept dt1_fin prompt          'End   Time (1) (dd/mm/yyyy hh24:mi:ss):'
accept dt2_ini prompt          'Start Time (2) (dd/mm/yyyy hh24:mi:ss):'
accept dt2_fin prompt          'End   Time (2) (dd/mm/yyyy hh24:mi:ss):'
accept instance_number prompt  'Instance Number ?.....................:'
accept top_n    Prompt         'Top N Queries ?.......................:'
accept Usrname  Prompt         'Somente Querys do usuário (null=todos):'

set serveroutput on size 1000000;
set feed off;
declare
   lv_dt1_ini date := to_date('&dt1_ini','dd/mm/yyyy hh24:mi:ss');
   lv_dt1_fin date := to_date('&dt1_fin','dd/mm/yyyy hh24:mi:ss');
   lv_dt2_ini date := to_date('&dt2_ini','dd/mm/yyyy hh24:mi:ss');
   lv_dt2_fin date := to_date('&dt2_fin','dd/mm/yyyy hh24:mi:ss');
   lv_instance_number number := to_number('&instance_number');
   lv_top_n    number := &top_n;
   --
   lv_snap1_ini    number;
   lv_snap1_fin    number;
   lv_snap2_ini    number;
   lv_snap2_fin    number;
   --
   lv_snap_time1_ini   date;
   lv_snap_time1_fin   date;
   lv_snap_time2_ini   date;
   lv_snap_time2_fin   date;
   --
   lv_dbid     number;
   lv_inst_num number;
   --
   cursor load_cur (p_snap_ini in number,
                    p_snap_fin in number,
					p_dbid     in number,
					p_inst_num in number,
					p_stat     in varchar2) is
	 Select nvl(e.value - b.value,0)
	   from DBA_HIST_SYSSTAT b,
			DBA_HIST_SYSSTAT e
	  where b.snap_id = p_snap_ini
		and e.snap_id = p_snap_fin
		and b.DBID    = p_dbid
		and b.dbid    = e.dbid
		and b.instance_number = p_inst_num
		and b.instance_number = e.instance_number
		and b.stat_name = p_stat
		and b.stat_name = e.stat_name;

   --
   cursor get_snap_id (p_data1 in date, p_data2 in date) is
     select min(snap_id), max(snap_id)
       from dba_hist_snapshot
      where BEGIN_INTERVAL_TIME between p_data1 and p_data2
        and instance_number = lv_instance_number;
   --
   cursor get_snap_info (p_snap_ini in number, p_snap_fin in number) is
     select i.BEGIN_INTERVAL_TIME snap_time, e.BEGIN_INTERVAL_TIME snap_time
       from dba_hist_snapshot i, dba_hist_snapshot e
      where i.snap_id         = p_snap_ini
        and e.snap_id         = p_snap_fin
		and e.instance_number = i.instance_number
        and e.startup_time    = i.startup_time;
   --
   cursor get_db is
     select d.dbid            dbid,
            lv_instance_number inst_num
       from v$database d;
   --
   lv_elapse1_seconds      number;
   lv_elapse2_seconds      number;
   --
   lv_Redo_size1           number;
   lv_Logical_reads1       number;
   lv_Block_changes1       number;
   lv_Physical_reads1      number;
   lv_hysical_writes1      number;
   lv_User_calls1          number;
   lv_Parses1              number;
   lv_Hard_parses1         number;
   lv_Sorts1               number;
   lv_Logons1              number;
   lv_Executes1            number;
   lv_commits1             number;
   lv_rollbacks1           number;
   lv_Transactions1        number;
   lv_Buffer_Hit1          number;
   lv_dbtime1              number;
   lv_iotime1              number;
   lv_clutime1             number;
   --
   lv_Redo_size2           number;
   lv_Logical_reads2       number;
   lv_Block_changes2       number;
   lv_Physical_reads2      number;
   lv_hysical_writes2      number;
   lv_User_calls2          number;
   lv_Parses2              number;
   lv_Hard_parses2         number;
   lv_Sorts2               number;
   lv_Logons2              number;
   lv_Executes2            number;
   lv_commits2             number;
   lv_rollbacks2           number;
   lv_Transactions2        number;
   lv_Buffer_Hit2          number;
   lv_dbtime2              number;
   lv_iotime2              number;
   lv_clutime2             number;

   --
   ------------------
   -- Top N events
   cursor top_N_cur (p_bid in number, p_eid in number, p_dbid in number, p_inst_num in number) is
      select substr(event,1,28) event
           , waits
           , time
        from (select e.event_name                          event
                   , e.total_waits - nvl(b.total_waits,0)  waits
                   , e.time_waited_micro - nvl(b.time_waited_micro,0)  time
                from DBA_HIST_SYSTEM_EVENT b
                   , DBA_HIST_SYSTEM_EVENT e
               where b.snap_id(+)          = p_bid
                 and e.snap_id             = p_eid
                 and b.dbid(+)             = p_dbid
                 and e.dbid                = p_dbid
                 and b.instance_number(+)  = p_inst_num
                 and e.instance_number     = p_inst_num
                 and b.event_name(+)       = e.event_name
                 and e.total_waits         > nvl(b.total_waits,0)
				 and e.wait_class          <> 'Idle'
                 order by time desc, waits desc
           )
      where rownum <= lv_top_n;

   -- Top N buffer_gets
   cursor top_n_buff_cur (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
	 Select *
       from ( select e.sql_id,
	                 --substr(e.TEXT_SUBSET,1,100) sql_text,
                     nvl((e.BUFFER_GETS_TOTAL - b.BUFFER_GETS_TOTAL),0) BufferGets,
                     nvl((e.EXECUTIONS_TOTAL  - b.EXECUTIONS_TOTAL ),0) Executions,
                     nvl(ROUND((e.buffer_gets_total - b.buffer_gets_total) /
                               (e.executions_total  - b.executions_total )),0) Buff_by_exec
                from DBA_HIST_SQLSTAT e
                   , DBA_HIST_SQLSTAT b
               where b.snap_id(+)         = p_bid
                 and b.dbid(+)            = e.dbid
                 and b.instance_number(+) = e.instance_number
				 and b.sql_id (+)         = e.sql_id
                 and e.snap_id            = p_eid
                 and e.dbid               = p_dbid
                 and e.instance_number    = p_inst_num
                 and e.buffer_gets_total        > nvl(b.buffer_gets_total,0)
                 and e.executions_total         > nvl(b.executions_total,0)
				 and e.parsing_schema_name like upper('&Usrname') ||'%'
				 and b.parsing_schema_name like upper('&Usrname') ||'%'
               order by BufferGets desc
            )
	  Where Rownum <= lv_top_n;

   -- Top N executions
   cursor top_n_exec_cur (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
     select sql_id, execs, bufferGets, Buff_by_exec
       from ( select e.sql_id,
                     nvl((e.buffer_gets_total - b.buffer_gets_total),0) BufferGets,
                     nvl((e.executions_total  - b.executions_total ),0) Execs,
                     nvl(ROUND((e.buffer_gets_total - b.buffer_gets_total) /
                               (e.executions_total  - b.executions_total )),0) Buff_by_exec,
					 nvl((e.cpu_time_total - b.cpu_time_total),0) cpu_time
                from DBA_HIST_SQLSTAT e
                   , DBA_HIST_SQLSTAT b
               where b.snap_id(+)         = p_bid
                 and b.dbid(+)            = e.dbid
                 and b.instance_number(+) = e.instance_number
                 and b.sql_id(+)          = e.sql_id
                 and e.snap_id            = p_eid
                 and e.dbid               = p_dbid
                 and e.instance_number    = p_inst_num
                 and e.buffer_gets_total        > nvl(b.buffer_gets_total,0)
                 and e.executions_total         > nvl(b.executions_total,0)
				 and e.parsing_schema_name like upper('&Usrname') ||'%'
				 and b.parsing_schema_name like upper('&Usrname') ||'%'
               order by Execs desc
           )
     where rownum <= lv_top_n;

   -- Top N BadSqls
   cursor top_n_bads_cur (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
     select sql_id, execs, bufferGets, Buff_by_exec
       from ( select e.sql_id,
                     nvl((e.buffer_gets_total - b.buffer_gets_total),0) BufferGets,
                     nvl((e.executions_total  - b.executions_total ),0) Execs,
                     nvl(ROUND((e.buffer_gets_total - b.buffer_gets_total) /
                           (e.executions_total  - b.executions_total )),0) Buff_by_exec,
					 nvl((e.cpu_time_total - b.cpu_time_total),0) cpu_time
                from DBA_HIST_SQLSTAT e
                   , DBA_HIST_SQLSTAT b
               where b.snap_id(+)         = p_bid
                 and b.dbid(+)            = e.dbid
                 and b.instance_number(+) = e.instance_number
                 and b.sql_id(+)          = e.sql_id
                 and e.snap_id            = p_eid
                 and e.dbid               = p_dbid
                 and e.instance_number    = p_inst_num
                 and e.buffer_gets_total        > nvl(b.buffer_gets_total,0)
                 and e.executions_total         > nvl(b.executions_total,0)
				 and e.parsing_schema_name like upper('&Usrname') ||'%'
				 and b.parsing_schema_name like upper('&Usrname') ||'%'
               order by Buff_by_exec desc
           )
     where rownum <= lv_top_n;

   -- Top N Physical Reads
   cursor top_n_disk_cur (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
     select sql_id, execs, bufferGets, diskreads, disk_by_exec
       from ( select e.sql_id,
                     nvl((e.buffer_gets_total - b.buffer_gets_total),0) BufferGets,
                     nvl((e.disk_reads_total - b.disk_reads_total),0) DiskReads,
                     nvl((e.executions_total  - b.executions_total ),0) Execs,
                     nvl(ROUND((e.disk_reads_total - b.disk_reads_total) /
                           (e.executions_total  - b.executions_total )),0) Disk_by_exec,
					 nvl((e.cpu_time_total - b.cpu_time_total),0) cpu_time
                from DBA_HIST_SQLSTAT e
                   , DBA_HIST_SQLSTAT b
               where b.snap_id(+)         = p_bid
                 and b.dbid(+)            = e.dbid
                 and b.instance_number(+) = e.instance_number
                 and b.sql_id(+)          = e.sql_id
                 and e.snap_id            = p_eid
                 and e.dbid               = p_dbid
                 and e.instance_number    = p_inst_num
                 and e.buffer_gets_total        > nvl(b.buffer_gets_total,0)
                 and e.executions_total         > nvl(b.executions_total,0)
				 and e.parsing_schema_name like upper('&Usrname') ||'%'
				 and b.parsing_schema_name like upper('&Usrname') ||'%'
               order by DiskReads desc
           )
     where rownum <= lv_top_n;

   --> Top N for Cpu_time
   cursor top_n_cpu_cur (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
     select sql_id, cpu_time, bufferGets, executions
       from ( select e.sql_id,
                     nvl((e.buffer_gets_total - b.buffer_gets_total),0) BufferGets,
                     nvl((e.executions_total  - b.executions_total ),0) Executions,
					 nvl((e.cpu_time_total - b.cpu_time_total),0) cpu_time
                from DBA_HIST_SQLSTAT e
                   , DBA_HIST_SQLSTAT b
               where b.snap_id(+)         = p_bid
                 and b.dbid(+)            = e.dbid
                 and b.instance_number(+) = e.instance_number
                 and b.sql_id(+)          = e.sql_id
                 and e.snap_id            = p_eid
                 and e.dbid               = p_dbid
                 and e.instance_number    = p_inst_num
                 and e.buffer_gets_total        > nvl(b.buffer_gets_total,0)
                 and e.executions_total         > nvl(b.executions_total,0)
				 and e.parsing_schema_name like upper('&Usrname') ||'%'
				 and b.parsing_schema_name like upper('&Usrname') ||'%'
               order by cpu_time desc
           )
     where rownum <= lv_top_n;

   --> Top N for Elapsed_time
   cursor top_n_ela_cur (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
     select sql_id, elapsed_time, bufferGets, executions
       from ( select e.sql_id,
                     nvl((e.buffer_gets_total - b.buffer_gets_total),0) BufferGets,
                     nvl((e.executions_total  - b.executions_total ),0) Executions,
					 nvl((e.elapsed_time_total - b.elapsed_time_total),0) elapsed_time
                from DBA_HIST_SQLSTAT e
                   , DBA_HIST_SQLSTAT b
               where b.snap_id(+)         = p_bid
                 and b.dbid(+)            = e.dbid
                 and b.instance_number(+) = e.instance_number
                 and b.sql_id(+)          = e.sql_id
                 and e.snap_id            = p_eid
                 and e.dbid               = p_dbid
                 and e.instance_number    = p_inst_num
                 and e.buffer_gets_total        > nvl(b.buffer_gets_total,0)
                 and e.executions_total         > nvl(b.executions_total,0)
				 and e.parsing_schema_name like upper('&Usrname') ||'%'
				 and b.parsing_schema_name like upper('&Usrname') ||'%'
               order by elapsed_time desc
           )
     where rownum <= lv_top_n;


   --
   type typ_string is table of varchar2(100);
   type typ_number is table of number;
   --
   tab_event1  typ_string;
   tab_waits1  typ_number;
   tab_time1   typ_number;
   tab_pcttot1 typ_number;
   --
   tab_event2  typ_string;
   tab_waits2  typ_number;
   tab_time2   typ_number;
   tab_pcttot2 typ_number;
   --
   tab_hash1           typ_string;
   tab_sqltext1        typ_string;
   tab_buffer_gets1    typ_number;
   tab_executions1     typ_number;
   tab_disk_reads1     typ_number;
   tab_buff_by_exec1   typ_number;
   --
   tab_hash2           typ_string;
   tab_sqltext2        typ_string;
   tab_buffer_gets2    typ_number;
   tab_executions2     typ_number;
   tab_disk_reads2     typ_number;
   tab_buff_by_exec2   typ_number;
   --
   tab_snapid1        typ_number;
   tab_filename1       typ_string;
   tab_total_io1       typ_number;
   tab_total_block1    typ_number;
   --
   tab_snapid2        typ_number;
   tab_filename2       typ_string;
   tab_total_io2       typ_number;
   tab_total_block2    typ_number;
   --
   lv_signal           varchar2(1);
   lv_dummy			   number;
   lv_sum1             number;
   lv_sum2             number;
begin
   --
   dbms_output.put_line (chr(10) || chr(10));
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Comparação de estatístias do perfstat.');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) || chr(10));
   --
   open get_db;
   fetch get_db into lv_dbid, lv_inst_num;
   close get_db;
   --
   open get_snap_id (lv_dt1_ini, lv_dt1_fin);
   fetch get_snap_id into lv_snap1_ini, lv_snap1_fin;
   close get_snap_id;
   --
   if (lv_snap1_ini is null or lv_snap1_fin is null) then
     raise_application_error (-20001,'Não foi possível encontrar estatística para o intervalo:' ||
                                      to_char(lv_dt1_ini,'dd/mm/yyyy hh24:mi:ss') || ' a ' ||
                                      to_char(lv_dt1_fin,'dd/mm/yyyy hh24:mi:ss'));
   end if;
   --
   open get_snap_id (lv_dt2_ini, lv_dt2_fin);
   fetch get_snap_id into lv_snap2_ini, lv_snap2_fin;
   close get_snap_id;
   --
   if (lv_snap2_ini is null or lv_snap2_fin is null) then
     raise_application_error (-20002,'Não foi possível encontrar estatística para o intervalo:' ||
                                      to_char(lv_dt2_ini,'dd/mm/yyyy hh24:mi:ss') || ' a ' ||
                                      to_char(lv_dt2_fin,'dd/mm/yyyy hh24:mi:ss'));
   end if;
   --
   open get_snap_info (lv_snap1_ini, lv_snap1_fin);
   fetch get_snap_info into lv_snap_time1_ini, lv_snap_time1_fin;
   close get_snap_info;
   if (lv_snap_time1_ini is null or lv_snap_time1_fin is null) then
      raise_application_error (-20003,'Existe um startup entre o intervalo:' ||
                                      to_char(lv_dt1_ini,'dd/mm/yyyy hh24:mi:ss') || ' a ' ||
                                      to_char(lv_dt1_fin,'dd/mm/yyyy hh24:mi:ss'));
   end if;
   --
   open get_snap_info (lv_snap2_ini, lv_snap2_fin);
   fetch get_snap_info into lv_snap_time2_ini, lv_snap_time2_fin;
   close get_snap_info;
   if (lv_snap_time2_ini is null or lv_snap_time2_fin is null) then
      raise_application_error (-20003,'Existe um startup entre o intervalo:' ||
                                      to_char(lv_dt2_ini,'dd/mm/yyyy hh24:mi:ss') || ' a ' ||
                                      to_char(lv_dt2_fin,'dd/mm/yyyy hh24:mi:ss'));
   end if;
   --
   lv_elapse1_seconds := round((lv_snap_time1_fin - lv_snap_time1_ini) * 24 * 60 * 60);
   lv_elapse2_seconds := round((lv_snap_time2_fin - lv_snap_time2_ini) * 24 * 60 * 60);
   --
   dbms_output.put_line ('................................................................................................');
   dbms_output.put_line ('Período Inicial        Período Final         Snap_id_ini    Snap_id_fin   Tempo Total em Minutos');
   dbms_output.put_line (To_char(lv_snap_time1_ini,'dd/mm/yyyy hh24:mi:ss ') || ' ' || To_char(lv_snap_time1_fin,'dd/mm/yyyy hh24:mi:ss      ') || lv_snap1_ini ||'            '||lv_snap1_fin||'           '||to_char(round(lv_elapse1_seconds / 60)));
   dbms_output.put_line (To_char(lv_snap_time2_ini,'dd/mm/yyyy hh24:mi:ss ') || ' ' || To_char(lv_snap_time2_fin,'dd/mm/yyyy hh24:mi:ss      ') || lv_snap2_ini ||'            '||lv_snap2_fin||'           '||to_char(round(lv_elapse2_seconds / 60)));
   dbms_output.put_line ('................................................................................................');
   --
   -- Período 1
   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'redo size'); fetch load_cur into lv_Redo_size1; Close load_cur;
   lv_Redo_size1       := round(lv_Redo_size1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'session logical reads'); fetch load_cur into lv_Logical_reads1; Close load_cur;
   lv_Logical_reads1   := round(lv_Logical_reads1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'physical reads'); fetch load_cur into lv_Physical_reads1; Close load_cur;
   lv_Physical_reads1  := round(lv_Physical_reads1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'user calls'); fetch load_cur into lv_User_calls1; Close load_cur;
   lv_User_calls1      := round(lv_User_calls1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'parse count (hard)'); fetch load_cur into lv_Hard_parses1; Close load_cur;
   lv_Hard_parses1     := round(lv_Hard_parses1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'logons cumulative'); fetch load_cur into lv_Logons1; Close load_cur;
   lv_Logons1          := round(lv_Logons1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'execute count'); fetch load_cur into lv_Executes1; Close load_cur;
   lv_Executes1        := round(lv_Executes1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'user commits'); fetch load_cur into lv_Commits1; Close load_cur;
   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'user rollbacks'); fetch load_cur into lv_Rollbacks1; Close load_cur;
   lv_Transactions1    := round((lv_Commits1+lv_Rollbacks1)/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'DB time'); fetch load_cur into lv_dbtime1; Close load_cur;
   lv_dbtime1        := round(lv_dbtime1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'user I/O wait time'); fetch load_cur into lv_iotime1; Close load_cur;
   lv_iotime1        := round(lv_iotime1/lv_elapse1_seconds);

   open load_cur(lv_snap1_ini,lv_snap1_fin,lv_dbid,lv_inst_num,'cluster time'); fetch load_cur into lv_clutime1; Close load_cur;
   lv_clutime1        := round(lv_clutime1/lv_elapse1_seconds);

   --
   -- Período 2
   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'redo size'); fetch load_cur into lv_Redo_size2; Close load_cur;
   lv_Redo_size2       := round(lv_Redo_size2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'session logical reads'); fetch load_cur into lv_Logical_reads2; Close load_cur;
   lv_Logical_reads2   := round(lv_Logical_reads2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'physical reads'); fetch load_cur into lv_Physical_reads2; Close load_cur;
   lv_Physical_reads2  := round(lv_Physical_reads2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'user calls'); fetch load_cur into lv_User_calls2; Close load_cur;
   lv_User_calls2      := round(lv_User_calls2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'parse count (hard)'); fetch load_cur into lv_Hard_parses2; Close load_cur;
   lv_Hard_parses2     := round(lv_Hard_parses2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'logons cumulative'); fetch load_cur into lv_Logons2; Close load_cur;
   lv_Logons2          := round(lv_Logons2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'execute count'); fetch load_cur into lv_Executes2; Close load_cur;
   lv_Executes2        := round(lv_Executes2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'user commits'); fetch load_cur into lv_Commits2; Close load_cur;
   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'user rollbacks'); fetch load_cur into lv_Rollbacks2; Close load_cur;
   lv_Transactions2    := round((lv_Commits2+lv_Rollbacks2)/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'DB time'); fetch load_cur into lv_dbtime2; Close load_cur;
   lv_dbtime2        := round(lv_dbtime2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'user I/O wait time'); fetch load_cur into lv_iotime2; Close load_cur;
   lv_iotime2        := round(lv_iotime2/lv_elapse2_seconds);

   open load_cur(lv_snap2_ini,lv_snap2_fin,lv_dbid,lv_inst_num,'cluster time'); fetch load_cur into lv_clutime2; Close load_cur;
   lv_clutime2        := round(lv_clutime2/lv_elapse2_seconds);


   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Load Profile (por segundo):');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );
   ---
   dbms_output.put_line ('...........................................');
   dbms_output.put_line ('...............: Período 1         Período 2');
   dbms_output.put_line ('...........................................');
   dbms_output.put_line ('Redo size......: ' || to_char(lv_Redo_size1     ,'999,999,999') || ' ' || to_char(lv_Redo_size2     ,'999,999,999') );
   dbms_output.put_line ('Logical reads..: ' || to_char(lv_Logical_reads1 ,'999,999,999') || ' ' || to_char(lv_Logical_reads2 ,'999,999,999') );
   dbms_output.put_line ('Physical reads.: ' || to_char(lv_Physical_reads1,'999,999,999') || ' ' || to_char(lv_Physical_reads2,'999,999,999') );
   dbms_output.put_line ('User calls.....: ' || to_char(lv_User_calls1    ,'999,999,999') || ' ' || to_char(lv_User_calls2    ,'999,999,999') );
   dbms_output.put_line ('Hard parses....: ' || to_char(lv_Hard_parses1   ,'999,999,999') || ' ' || to_char(lv_Hard_parses2   ,'999,999,999') );
   dbms_output.put_line ('Logons.........: ' || to_char(lv_Logons1        ,'999,999,999') || ' ' || to_char(lv_Logons2        ,'999,999,999') );
   dbms_output.put_line ('Executes.......: ' || to_char(lv_Executes1      ,'999,999,999') || ' ' || to_char(lv_Executes2      ,'999,999,999') );
   dbms_output.put_line ('Transactions...: ' || to_char(lv_Transactions1  ,'999,999,999') || ' ' || to_char(lv_Transactions2  ,'999,999,999') );
   dbms_output.put_line ('Db Time........: ' || to_char(lv_dbtime1        ,'999,999,999') || ' ' || to_char(lv_dbtime2        ,'999,999,999') );
   dbms_output.put_line ('IO Time........: ' || to_char(lv_IOtime1        ,'999,999,999') || ' ' || to_char(lv_IOtime2        ,'999,999,999') );
   dbms_output.put_line ('Cluster time...: ' || to_char(lv_clutime1       ,'999,999,999') || ' ' || to_char(lv_clutime2       ,'999,999,999') );
   dbms_output.put_line ('...........................................');
   --
   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' Events');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );
   --
   open top_N_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_N_cur bulk collect into tab_event1, tab_waits1, tab_time1;
   close top_N_cur;
   --
   open top_N_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_N_cur bulk collect into tab_event2, tab_waits2, tab_time2;
   close top_N_cur;
   --
   dbms_output.put_line ('...|....................... Periodo 1 ............................|....................... Periodo 2 ............................|');
   dbms_output.put_line ('Top| Event                              Waits            Time(cs) | Event                               Waits            Time(cs)|');
   dbms_output.put_line ('...|..............................................................|..............................................................|');
   --
   for i in 1..lv_top_n
   loop
      if (tab_event1(i) = tab_event2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') || lv_signal ||'| ' ||rpad(tab_event1(i),25,' ') ||' '||to_char(tab_waits1(i),'9,999,999,999')||' '||to_char(tab_time1(i),'99,999,999,999,999')||' | '
                                                                ||rpad(tab_event2(i),25,' ') ||' '||to_char(tab_waits2(i),'9,999,999,999')||' '||to_char(tab_time2(i),'99,999,999,999,999')||' | ');
   end loop;
   dbms_output.put_line ('...|..............................................................|..............................................................|');

   --
   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' SQLs by Buffer gets:');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );

   open top_n_buff_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_buff_cur bulk collect into tab_hash1, tab_buffer_gets1, tab_executions1, tab_buff_by_exec1;
   close top_n_buff_cur;
   --
   open top_n_buff_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_buff_cur bulk collect into tab_hash2, tab_buffer_gets2, tab_executions2, tab_buff_by_exec2;
   close top_n_buff_cur;


   dbms_output.put_line ('...|....................... Periodo 1 ...........................|....................... Periodo 2 ...........................|');
   dbms_output.put_line ('Top|   sqlid            BufGets          Execs       Gets/Execs  |   sqlid           BufGets          Execs       Gets/Execs   |');
   dbms_output.put_line ('...|.............................................................|.............................................................|');

   lv_sum1 := 0;
   lv_sum2 := 0;
   for i in 1..lv_top_n
   loop
      if (tab_hash1(i) = tab_hash2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') ||lv_signal||'| ' ||tab_hash1(i)||' '||to_char(tab_buffer_gets1(i),'9,999,999,999')||' '||to_char(tab_executions1(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec1(i),'999,999,999') || '    | '
                                                              ||tab_hash2(i)||' '||to_char(tab_buffer_gets2(i),'9,999,999,999')||' '||to_char(tab_executions2(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec2(i),'999,999,999') || '    | ');
	  lv_sum1 := lv_sum1 + tab_buffer_gets1(i);
	  lv_sum2 := lv_sum2 + tab_buffer_gets2(i);
   end loop;

   dbms_output.put_line ('...|.............................................................|.............................................................|');
   dbms_output.put_line ('Total 1:'||to_char(lv_sum1,'9,999,999,999,999'));
   dbms_output.put_line ('Total 2:'||to_char(lv_sum2,'9,999,999,999,999'));
   -- Show Text
   /*
   dbms_output.put_line ('TEXTS:');
   for i in 1..lv_top_n
   loop
      dbms_output.put_line (to_char(i,'09') || '  '||to_char(tab_hash1(i),'999999999999')||' '||tab_sqltext1(i));
      if (tab_hash1(i) <> tab_hash2(i)) then
         dbms_output.put_line (to_char(i,'09') || '* '||to_char(tab_hash2(i),'999999999999')||' '||tab_sqltext2(i));
      end if;
   end loop;
   */


   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' SQLs by Executions:');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );

   open top_n_exec_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_exec_cur bulk collect into tab_hash1,tab_executions1, tab_buffer_gets1, tab_buff_by_exec1;
   close top_n_exec_cur;
   --
   open top_n_exec_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_exec_cur bulk collect into tab_hash2,tab_executions2, tab_buffer_gets2, tab_buff_by_exec2;
   close top_n_exec_cur;


   dbms_output.put_line ('...|....................... Periodo 1 ...........................|....................... Periodo 2 ...........................|');
   dbms_output.put_line ('Top|   SqlId            Executions       BufferGets  Gets/Execs  |   SqlId           Executions       BufferGets  Gets/Execs   |');
   dbms_output.put_line ('...|.............................................................|.............................................................|');

   lv_sum1 := 0;
   lv_sum2 := 0;

   for i in 1..lv_top_n
   loop
      if (tab_hash1(i) = tab_hash2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') ||lv_signal||'| ' ||tab_hash1(i)||' '||to_char(tab_executions1(i),'9,999,999,999')||' '||to_char(tab_buffer_gets1(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec1(i),'999,999,999') || '    | '
                                                              ||tab_hash2(i)||' '||to_char(tab_executions2(i),'9,999,999,999')||' '||to_char(tab_buffer_gets2(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec2(i),'999,999,999') || '    | ');
	  lv_sum1 := lv_sum1 + tab_executions1(i);
	  lv_sum2 := lv_sum2 + tab_executions2(i);

   end loop;

   dbms_output.put_line ('...|.............................................................|.............................................................|');
   dbms_output.put_line ('Total 1:'||to_char(lv_sum1,'9,999,999,999,999'));
   dbms_output.put_line ('Total 2:'||to_char(lv_sum2,'9,999,999,999,999'));

   /*
   -- Show Text
   dbms_output.put_line ('TEXTS:');
   for i in 1..lv_top_n
   loop
      dbms_output.put_line (to_char(i,'09') || '  '||to_char(tab_hash1(i),'999999999999')||' '||tab_sqltext1(i));
      if (tab_hash1(i) <> tab_hash2(i)) then
         dbms_output.put_line (to_char(i,'09') || '* '||to_char(tab_hash2(i),'999999999999')||' '||tab_sqltext2(i));
      end if;
   end loop;
   --
   */
   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' Bad sqls:');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );

   open top_n_bads_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_bads_cur bulk collect into tab_hash1, tab_executions1, tab_buffer_gets1, tab_buff_by_exec1;
   close top_n_bads_cur;
   --
   open top_n_bads_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_bads_cur bulk collect into tab_hash2, tab_executions2, tab_buffer_gets2, tab_buff_by_exec2;
   close top_n_bads_cur;


   dbms_output.put_line ('...|....................... Periodo 1 ...........................|....................... Periodo 2 ...........................|');
   dbms_output.put_line ('Top|   SqlId            Executions       BufferGets  Gets/Execs  |   SqlId           Executions       BufferGets  Gets/Execs   |');
   dbms_output.put_line ('...|.............................................................|.............................................................|');
   lv_sum1 := 0;
   lv_sum2 := 0;

   for i in 1..lv_top_n
   loop
      if (tab_hash1(i) = tab_hash2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') ||lv_signal||'| ' ||tab_hash1(i)||' '||to_char(tab_executions1(i),'9,999,999,999')||' '||to_char(tab_buffer_gets1(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec1(i),'999,999,999') || '    | '
                                                              ||tab_hash2(i)||' '||to_char(tab_executions2(i),'9,999,999,999')||' '||to_char(tab_buffer_gets2(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec2(i),'999,999,999') || '    | ');
	  lv_sum1 := lv_sum1 + tab_buffer_gets1(i);
	  lv_sum2 := lv_sum2 + tab_buffer_gets2(i);
   end loop;

   dbms_output.put_line ('...|.............................................................|.............................................................|');
   dbms_output.put_line ('Total 1:'||to_char(lv_sum1,'9,999,999,999,999'));
   dbms_output.put_line ('Total 2:'||to_char(lv_sum2,'9,999,999,999,999'));

   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('*****************************************');
   dbms_output.put_line ('Top '||lv_top_n||' Bad sqls (Disk Reads):');
   dbms_output.put_line ('*****************************************');
   dbms_output.put_line (chr(10) );

   open top_n_disk_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_disk_cur bulk collect into tab_hash1, tab_executions1, tab_buffer_gets1, tab_disk_reads1, tab_buff_by_exec1;
   close top_n_disk_cur;
   --
   open top_n_disk_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_disk_cur bulk collect into tab_hash2, tab_executions2, tab_buffer_gets2, tab_disk_reads2, tab_buff_by_exec2;
   close top_n_disk_cur;


   dbms_output.put_line ('...|....................... Periodo 1 ..........................................|......................... Periodo 2 .....................................|');
   dbms_output.put_line ('Top|   SqlId            Executions       BufferGets   DiskReads     Disk/Execs  |   SqlId           Executions       BufferGets  DiskReads   Disk/Execs   |');
   dbms_output.put_line ('...|............................................................................|.........................................................................|');
   lv_sum1 := 0;
   lv_sum2 := 0;

   for i in 1..lv_top_n
   loop
      if (tab_hash1(i) = tab_hash2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') ||lv_signal||'| ' ||tab_hash1(i)||' '||to_char(tab_executions1(i),'9,999,999,999')||' '||to_char(tab_buffer_gets1(i),'9,999,999,999')||' '||to_char(tab_disk_reads1(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec1(i),'999,999,999') || '    | '
                                                              ||tab_hash2(i)||' '||to_char(tab_executions2(i),'9,999,999,999')||' '||to_char(tab_buffer_gets2(i),'9,999,999,999')||' '||to_char(tab_disk_reads2(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec2(i),'999,999,999') || ' | ');
	  lv_sum1 := lv_sum1 + tab_disk_reads1(i);
	  lv_sum2 := lv_sum2 + tab_disk_reads2(i);
   end loop;

   dbms_output.put_line ('...|............................................................................|.........................................................................|');
   dbms_output.put_line ('Total 1:'||to_char(lv_sum1,'9,999,999,999,999'));
   dbms_output.put_line ('Total 2:'||to_char(lv_sum2,'9,999,999,999,999'));

   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' SQLs by CPU Time...:');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );

   open top_n_cpu_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_cpu_cur bulk collect into tab_hash1, tab_buff_by_exec1, tab_buffer_gets1, tab_executions1;
   close top_n_cpu_cur;
   --
   open top_n_cpu_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_cpu_cur bulk collect into tab_hash2, tab_buff_by_exec2, tab_buffer_gets2, tab_executions2;
   close top_n_cpu_cur;


   dbms_output.put_line ('...|....................... Periodo 1 ...........................|....................... Periodo 2 ...........................|');
   dbms_output.put_line ('Top|   sqlid            BufGets          Execs       Cpu Time    |   sqlid           BufGets          Execs       Cpu Time     |');
   dbms_output.put_line ('...|.............................................................|.............................................................|');
   lv_sum1 := 0;
   lv_sum2 := 0;

   for i in 1..lv_top_n
   loop
      if (tab_hash1(i) = tab_hash2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') ||lv_signal||'| ' ||tab_hash1(i)||' '||to_char(tab_buffer_gets1(i),'9,999,999,999')||' '||to_char(tab_executions1(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec1(i),'999,999,999,999') || '    | '
                                                              ||tab_hash2(i)||' '||to_char(tab_buffer_gets2(i),'9,999,999,999')||' '||to_char(tab_executions2(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec2(i),'999,999,999,999') || '    | ');
	  lv_sum1 := lv_sum1 + tab_buff_by_exec1(i);
	  lv_sum2 := lv_sum2 + tab_buff_by_exec2(i);
   end loop;
   dbms_output.put_line ('Total 1:'||to_char(lv_sum1,'9,999,999,999,999'));
   dbms_output.put_line ('Total 2:'||to_char(lv_sum2,'9,999,999,999,999'));

   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' SQLs by Elapsed Time...:');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );

   open top_n_ela_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_ela_cur bulk collect into tab_hash1, tab_buff_by_exec1, tab_buffer_gets1, tab_executions1;
   close top_n_ela_cur;
   --
   open top_n_ela_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_ela_cur bulk collect into tab_hash2, tab_buff_by_exec2, tab_buffer_gets2, tab_executions2;
   close top_n_ela_cur;


   dbms_output.put_line ('...|....................... Periodo 1 ...........................|....................... Periodo 2 ...........................|');
   dbms_output.put_line ('Top|   sqlid            BufGets          Execs      Elapsed Time |   sqlid           BufGets          Execs       Elapsed Time |');
   dbms_output.put_line ('...|.............................................................|.............................................................|');
   lv_sum1 := 0;
   lv_sum2 := 0;

   for i in 1..lv_top_n
   loop
      if (tab_hash1(i) = tab_hash2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') ||lv_signal||'| ' ||tab_hash1(i)||' '||to_char(tab_buffer_gets1(i),'9,999,999,999')||' '||to_char(tab_executions1(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec1(i),'999,999,999,999') || '    | '
                                                              ||tab_hash2(i)||' '||to_char(tab_buffer_gets2(i),'9,999,999,999')||' '||to_char(tab_executions2(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec2(i),'999,999,999,999') || '    | ');
	  lv_sum1 := lv_sum1 + tab_buff_by_exec1(i);
	  lv_sum2 := lv_sum2 + tab_buff_by_exec2(i);
   end loop;
   dbms_output.put_line ('Total 1:'||to_char(lv_sum1,'9,999,999,999,999'));
   dbms_output.put_line ('Total 2:'||to_char(lv_sum2,'9,999,999,999,999'));

end;
/

set feed on;

Prompt End of report.
