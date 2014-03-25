
accept dt1_ini prompt          'Start Time (1) (dd/mm/yyyy hh24:mi:ss):'
accept dt1_fin prompt          'End   Time (1) (dd/mm/yyyy hh24:mi:ss):'
accept dt2_ini prompt          'Start Time (2) (dd/mm/yyyy hh24:mi:ss):'
accept dt2_fin prompt          'End   Time (2) (dd/mm/yyyy hh24:mi:ss):'
accept instance_number prompt  'Instance Number ?.....................:'
accept top_n    Prompt         'Top N Queries ?.......................:'
accept top_n_io Prompt         'Top N Datafiles ?.....................:'
Prompt Order by clausule should be:
Prompt bufferGets, executions, Buff_by_exec, cpu_time, rows_processed, disk_reads or elapsed_time
Accept ordclaus Prompt         'OrderBy clausule......................:'



set serveroutput on size 1000000;
set feed off;
declare
   lv_dt1_ini date := to_date('&dt1_ini','dd/mm/yyyy hh24:mi:ss');
   lv_dt1_fin date := to_date('&dt1_fin','dd/mm/yyyy hh24:mi:ss');
   lv_dt2_ini date := to_date('&dt2_ini','dd/mm/yyyy hh24:mi:ss');
   lv_dt2_fin date := to_date('&dt2_fin','dd/mm/yyyy hh24:mi:ss');
   lv_instance_number number := to_number('&instance_number');
   lv_top_n    number := &top_n;
   lv_top_n_io number := &top_n_io;
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
   --
   cursor get_snap_id (p_data1 in date, p_data2 in date) is
     select min(snap_id), max(snap_id)
       from perfstat.stats$snapshot
      where snap_time between p_data1 and p_data2
        and instance_number = lv_instance_number;
   --
   cursor get_snap_info (p_snap_ini in number, p_snap_fin in number) is
     select i.snap_time, e.snap_time
       from perfstat.stats$snapshot i, perfstat.stats$snapshot e
      where i.snap_id      = p_snap_ini
        and e.snap_id      = p_snap_fin
        and e.startup_time = i.startup_time;
   --
   cursor get_db is
     select d.dbid            dbid,
            i.instance_number inst_num
       from v$database d,
            v$instance i;
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
   lv_Transactions1        number;
   lv_Buffer_Hit1          number;
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
   lv_Transactions2        number;
   lv_Buffer_Hit2          number;
   --
   lhtr   number;
   bfwt   number;
   tran   number;
   chng   number;
   ucal   number;
   urol   number;
   ucom   number;
   rsiz   number;
   phyr   number;
   phyw   number;
   prse   number;
   hprs   number;
   recr   number;
   gets   number;
   rlsr   number;
   rent   number;
   srtm   number;
   srtd   number;
   srtr   number;
   strn   number;
   call   number;
   lhr    number;
   sp     varchar2(512);
   bc     varchar2(512);
   lb     varchar2(512);
   bs     varchar2(512);
   twt    number;
   logc   number;
   prscpu number;
   prsela number;
   tcpu   number;
   exe    number;
   bspm   number;
   espm   number;
   bfrm   number;
   efrm   number;
   blog   number;
   elog   number;
   BOCUR   NUMBER;
   EOCUR   NUMBER;
   DMSD    NUMBER;
   DMFC    NUMBER;
   DMSI    NUMBER;
   PMRV    NUMBER;
   PMPT    NUMBER;
   NPMRV   NUMBER;
   NPMPT   NUMBER;
   DBFR    NUMBER;
   DPMS    NUMBER;
   DNPMS   NUMBER;
   GLSG    NUMBER;
   GLAG    NUMBER;
   GLGT    NUMBER;
   GLSC    NUMBER;
   GLAC    NUMBER;
   GLCT    NUMBER;
   GLRL    NUMBER;
   GCDFR   NUMBER;
   GCGE    NUMBER;
   GCGT    NUMBER;
   GCCV    NUMBER;
   GCCT    NUMBER;
   GCCRRV  NUMBER;
   GCCRRT  NUMBER;
   GCCURV  NUMBER;
   GCCURT  NUMBER;
   GCCRSV  NUMBER;
   GCCRBT  NUMBER;
   GCCRFT  NUMBER;
   GCCRST  NUMBER;
   GCCUSV  NUMBER;
   GCCUPT  NUMBER;
   GCCUFT  NUMBER;
   GCCUST  NUMBER;
   MSGSQ   NUMBER;
   MSGSQT  NUMBER;
   MSGSQK  NUMBER;
   MSGSQTK NUMBER;
   MSGRQ   NUMBER;
   MSGRQT  NUMBER;
   PHYRD   number;
   PHYRDL  number;
   ------------------
   -- Top N events
   cursor top_N_cur (p_bid in number, p_eid in number, p_dbid in number, p_inst_num in number, p_twt in number) is
      select substr(event,1,28) event
           , waits
           , time
           , pctwtt
        from (select e.event                               event
                   , e.total_waits - nvl(b.total_waits,0)  waits
                   , e.time_waited_micro - nvl(b.time_waited_micro,0)  time
                   , decode(p_twt, 0, 0,
                      100*((e.time_waited_micro - nvl(b.time_waited_micro,0))/p_twt))  pctwtt
                from stats$system_event b
                   , stats$system_event e
               where b.snap_id(+)          = p_bid
                 and e.snap_id             = p_eid
                 and b.dbid(+)             = p_dbid
                 and e.dbid                = p_dbid
                 and b.instance_number(+)  = p_inst_num
                 and e.instance_number     = p_inst_num
                 and b.event(+)            = e.event
                 and e.total_waits         > nvl(b.total_waits,0)
                 and e.event not in
                     ( select event
                         from stats$idle_event
                     )
                 order by time desc, waits desc
           )
      where rownum <= lv_top_n;

   -- Top N buffer_gets
   cursor top_n_buff_cur (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
     select hash_value, sql_text, bufferGets, executions, Buff_by_exec, cpu_time, rows_processed, disk_reads, elapsed_time
       from ( select e.hash_value, substr(e.TEXT_SUBSET,1,100) sql_text,
                     nvl((e.buffer_gets - b.buffer_gets),0) BufferGets,
                     nvl((e.executions  - b.executions ),0) Executions,
                     nvl(ROUND((e.buffer_gets - b.buffer_gets) /
                               (e.executions  - b.executions )),0) Buff_by_exec,
					 nvl((e.cpu_time - b.cpu_time),0) cpu_time,
					 nvl((e.rows_processed - b.rows_processed),0) rows_processed,
					 nvl((e.disk_reads - b.disk_reads),0) disk_reads,
					 nvl((e.elapsed_time - b.elapsed_time),0) elapsed_time
                from stats$sql_summary e
                   , stats$sql_summary b
               where b.snap_id(+)         = p_bid
                 and b.dbid(+)            = e.dbid
                 and b.instance_number(+) = e.instance_number
                 and b.hash_value(+)      = e.hash_value
                 and b.address(+)         = e.address
                 and b.text_subset(+)     = e.text_subset
                 and e.snap_id            = p_eid
                 and e.dbid               = p_dbid
                 and e.instance_number    = p_inst_num
                 and e.buffer_gets        > nvl(b.buffer_gets,0)
                 and e.executions         > nvl(b.executions,0)
				 Order by &ordclaus desc
           )
     where rownum <= lv_top_n;

   -- File IO
   cursor top_n_file_io        (p_bid        in number,
                          p_eid        in number,
                          p_dbid       in number,
                          p_inst_num   in number) is
     select snapid,filename,total_io,total_block
     from ( select b.snap_id snapid,
                   b.filename,
                   nvl(( (e.phyrds+e.phywrts) - (b.phyrds+b.phywrts) ),0) total_io,
                   nvl(( (e.phyblkrd+e.phyblkwrt) - (b.phyblkrd+b.phyblkwrt) ),0) total_block
            from stats$filestatxs e
               , stats$filestatxs b
            where b.snap_id(+)         = p_bid
              and b.dbid(+)            = e.dbid
              and b.instance_number(+) = e.instance_number
              and b.filename(+)        = e.filename
              and e.snap_id            = p_eid
              and e.dbid               = p_dbid
              and e.instance_number    = p_inst_num
            order by total_io desc
          )
       where rownum <= lv_top_n_io;


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
   tab_hash1           typ_number;
   tab_sqltext1        typ_string;
   tab_buffer_gets1    typ_number;
   tab_executions1     typ_number;
   tab_disk_reads1     typ_number;
   tab_buff_by_exec1   typ_number;
   tab_cpu_time1       typ_number;
   tab_rows_processed1 typ_number;
   tab_elapsed_time1   typ_number;

   --
   tab_hash2           typ_number;
   tab_sqltext2        typ_string;
   tab_buffer_gets2    typ_number;
   tab_executions2     typ_number;
   tab_disk_reads2     typ_number;
   tab_buff_by_exec2   typ_number;
   tab_cpu_time2       typ_number;
   tab_rows_processed2 typ_number;
   tab_elapsed_time2   typ_number;

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
   --
   lv_sum1          number;
   lv_sum2          number;

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
   PERFSTAT.STATSPACK.STAT_CHANGES
   ( lv_snap1_ini
   , lv_snap1_fin
   , lv_dbid
   , lv_inst_num  -- End of IN arguments
   , null
   , lhtr
   ,   bfwt
   , tran
   ,   chng
   , ucal
   ,   urol
   , rsiz
   ,   phyr
   , phyrd
   , phyrdl
   , phyw
   ,   ucom
   , prse
   ,   hprs
   , recr
   ,   gets
   , rlsr
   ,   rent
   , srtm
   ,   srtd
   , srtr
   ,   strn
   , lhr
   ,    bc
   , sp
   ,     lb
   , bs
   ,     twt
   , logc
   ,   prscpu
   , tcpu
   ,   exe
   , prsela
   , bspm
   ,   espm
   , bfrm
   , efrm
   , blog
   ,   elog
   , BOCUR
   , EOCUR
   , DMSD
   , DMFC
   , DMSI
   , PMRV
   , PMPT
   , NPMRV
   , NPMPT
   , DBFR
   , DPMS
   , DNPMS
   , GLSG
   , GLAG
   , GLGT
   , GLSC
   , GLAC
   , GLCT
   , GLRL
   , GCDFR
   , GCGE
   , GCGT
   , GCCV
   , GCCT
   , GCCRRV
   , GCCRRT
   , GCCURV
   , GCCURT
   , GCCRSV
   , GCCRBT
   , GCCRFT
   , GCCRST
   , GCCUSV
   , GCCUPT
   , GCCUFT
   , GCCUST
   , MSGSQ
   , MSGSQT
   , MSGSQK
   , MSGSQTK
   , MSGRQ
   , MSGRQT
   );
   call := ucal + recr;
   --
   lv_Redo_size1       := round(rsiz/lv_elapse1_seconds);
   lv_Logical_reads1   := round(gets/lv_elapse1_seconds);
   lv_Block_changes1   := round(chng/lv_elapse1_seconds);
   lv_Physical_reads1  := round(phyr/lv_elapse1_seconds);
   lv_hysical_writes1  := round(phyw/lv_elapse1_seconds);
   lv_User_calls1      := round(ucal/lv_elapse1_seconds);
   lv_Parses1          := round(prse/lv_elapse1_seconds);
   lv_Hard_parses1     := round(hprs/lv_elapse1_seconds);
   lv_Sorts1           := round((srtm+srtd)/lv_elapse1_seconds);
   lv_Logons1          := round(logc/lv_elapse1_seconds);
   lv_Executes1        := round(exe/lv_elapse1_seconds);
   lv_Transactions1    := round(tran/lv_elapse1_seconds);
   lv_Buffer_Hit1      := round(100*(1-phyr/gets),2);
   --
   STATSPACK.STAT_CHANGES
   ( lv_snap2_ini
   , lv_snap2_fin
   , lv_dbid
   , lv_inst_num  -- End of IN arguments
   , null
   , lhtr
   ,   bfwt
   , tran
   ,   chng
   , ucal
   ,   urol
   , rsiz
   ,   phyr
   , phyrd
   , phyrdl
   , phyw
   ,   ucom
   , prse
   ,   hprs
   , recr
   ,   gets
   , rlsr
   ,   rent
   , srtm
   ,   srtd
   , srtr
   ,   strn
   , lhr
   ,    bc
   , sp
   ,     lb
   , bs
   ,     twt
   , logc
   ,   prscpu
   , tcpu
   ,   exe
   , prsela
   , bspm
   ,   espm
   , bfrm
   , efrm
   , blog
   ,   elog
   , BOCUR
   , EOCUR
   , DMSD
   , DMFC
   , DMSI
   , PMRV
   , PMPT
   , NPMRV
   , NPMPT
   , DBFR
   , DPMS
   , DNPMS
   , GLSG
   , GLAG
   , GLGT
   , GLSC
   , GLAC
   , GLCT
   , GLRL
   , GCDFR
   , GCGE
   , GCGT
   , GCCV
   , GCCT
   , GCCRRV
   , GCCRRT
   , GCCURV
   , GCCURT
   , GCCRSV
   , GCCRBT
   , GCCRFT
   , GCCRST
   , GCCUSV
   , GCCUPT
   , GCCUFT
   , GCCUST
   , MSGSQ
   , MSGSQT
   , MSGSQK
   , MSGSQTK
   , MSGRQ
   , MSGRQT
   );
   call := ucal + recr;
   --
   lv_Redo_size2       := round(rsiz/lv_elapse1_seconds);
   lv_Logical_reads2   := round(gets/lv_elapse1_seconds);
   lv_Block_changes2   := round(chng/lv_elapse1_seconds);
   lv_Physical_reads2  := round(phyr/lv_elapse1_seconds);
   lv_hysical_writes2  := round(phyw/lv_elapse1_seconds);
   lv_User_calls2      := round(ucal/lv_elapse1_seconds);
   lv_Parses2          := round(prse/lv_elapse1_seconds);
   lv_Hard_parses2     := round(hprs/lv_elapse1_seconds);
   lv_Sorts2           := round((srtm+srtd)/lv_elapse1_seconds);
   lv_Logons2          := round(logc/lv_elapse1_seconds);
   lv_Executes2        := round(exe/lv_elapse1_seconds);
   lv_Transactions2    := round(tran/lv_elapse1_seconds);
   lv_Buffer_Hit2      := round(100*(1-phyr/gets),2);
   --

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
   dbms_output.put_line ('Block changes..: ' || to_char(lv_Block_changes1 ,'999,999,999') || ' ' || to_char(lv_Block_changes2 ,'999,999,999') );
   dbms_output.put_line ('Physical reads.: ' || to_char(lv_Physical_reads1,'999,999,999') || ' ' || to_char(lv_Physical_reads2,'999,999,999') );
   dbms_output.put_line ('Physical writes: ' || to_char(lv_hysical_writes1,'999,999,999') || ' ' || to_char(lv_hysical_writes2,'999,999,999') );
   dbms_output.put_line ('User calls.....: ' || to_char(lv_User_calls1    ,'999,999,999') || ' ' || to_char(lv_User_calls2    ,'999,999,999') );
   dbms_output.put_line ('Parses.........: ' || to_char(lv_Parses1        ,'999,999,999') || ' ' || to_char(lv_Parses2        ,'999,999,999') );
   dbms_output.put_line ('Hard parses....: ' || to_char(lv_Hard_parses1   ,'999,999,999') || ' ' || to_char(lv_Hard_parses2   ,'999,999,999') );
   dbms_output.put_line ('Sorts..........: ' || to_char(lv_Sorts1         ,'999,999,999') || ' ' || to_char(lv_Sorts2         ,'999,999,999') );
   dbms_output.put_line ('Logons.........: ' || to_char(lv_Logons1        ,'999,999,999') || ' ' || to_char(lv_Logons2        ,'999,999,999') );
   dbms_output.put_line ('Executes.......: ' || to_char(lv_Executes1      ,'999,999,999') || ' ' || to_char(lv_Executes2      ,'999,999,999') );
   dbms_output.put_line ('Transactions...: ' || to_char(lv_Transactions1  ,'999,999,999') || ' ' || to_char(lv_Transactions2  ,'999,999,999') );
   dbms_output.put_line ('Buffer  Hit   %: ' || to_char(lv_Buffer_Hit1    ,'9999,999.99') || ' ' || to_char(lv_Buffer_Hit2    ,'9999,999.99') );
   dbms_output.put_line ('...........................................');
   --
   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' Events');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );
   --
   open top_N_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num, twt);
   fetch top_N_cur bulk collect into tab_event1, tab_waits1, tab_time1, tab_pcttot1;
   close top_N_cur;
   --
   open top_N_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num, twt);
   fetch top_N_cur bulk collect into tab_event2, tab_waits2, tab_time2, tab_pcttot2;
   close top_N_cur;
   --
   dbms_output.put_line ('...|....................... Periodo 1 ...................................|....................... Periodo 2....................................|');
   dbms_output.put_line ('Top| Event                              Waits         Time(cs)    PctTot | Event                              Waits         Time(cs)    PctTot |');
   dbms_output.put_line ('...|.....................................................................|.....................................................................|');
   --
   for i in 1..lv_top_n
   loop
      if (tab_event1(i) = tab_event2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') || lv_signal ||'| ' ||rpad(tab_event1(i),25,' ') ||' '||to_char(tab_waits1(i),'9,999,999,999')||' '||to_char(tab_time1(i),'99,999,999,999,999')||' '||to_char(tab_pcttot1(i),'90.00') || ' | '
                                                                ||rpad(tab_event2(i),25,' ') ||' '||to_char(tab_waits2(i),'9,999,999,999')||' '||to_char(tab_time2(i),'99,999,999,999,999')||' '||to_char(tab_pcttot2(i),'90.00') || ' | ');
   end loop;
   dbms_output.put_line ('...|.............................................................|.............................................................|');

   --
   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Top '||lv_top_n||' SQLs by Buffer gets:');
   dbms_output.put_line ('**************************************');
   dbms_output.put_line (chr(10) );

   open top_n_buff_cur (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_buff_cur bulk collect into tab_hash1, tab_sqltext1,  tab_buffer_gets1, tab_executions1, tab_buff_by_exec1,tab_cpu_time1, tab_rows_processed1, tab_disk_reads1, tab_elapsed_time1 ;
   close top_n_buff_cur;
   --
   open top_n_buff_cur (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_buff_cur bulk collect into tab_hash2, tab_sqltext2,  tab_buffer_gets2, tab_executions2, tab_buff_by_exec2, tab_cpu_time2, tab_rows_processed2, tab_disk_reads2, tab_elapsed_time2;
   close top_n_buff_cur;


   dbms_output.put_line ('...|....................... Periodo 1 ...............................................................................|....................... Periodo 2 ...............................................................................|');
   dbms_output.put_line ('Top|   Hash             BufGets             Execs  Gets/Execs    RowsProc   DiskReads     CpuTime       ElapsedTime  |   Hash              BufGets          Execs   Gets/Execs      RowsProc    DiskReads  CpuTime    ElapsedTime      |');
   dbms_output.put_line ('...|.................................................................................................................|.................................................................................................................|');
   lv_sum1 := 0;
   lv_sum2 := 0;

   for i in 1..lv_top_n
   loop
      if (tab_hash1(i) = tab_hash2(i)) then
        lv_signal := ' ';
      else
        lv_signal := '*';
      end if;
      dbms_output.put_line (to_char(i,'09') ||lv_signal||'| ' ||to_char(tab_hash1(i),'999999999999')||' '||to_char(tab_buffer_gets1(i),'9,999,999,999')||' '||to_char(tab_executions1(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec1(i),'999,999,999') ||to_char(tab_rows_processed1(i),'999,999,999') ||to_char(tab_disk_reads1(i),'999,999,999') ||to_char(tab_cpu_time1(i),'999,999,999') ||to_char(tab_elapsed_time1(i),'999,999,999,999') || '    | '
                                                              ||to_char(tab_hash2(i),'999999999999')||' '||to_char(tab_buffer_gets2(i),'9,999,999,999')||' '||to_char(tab_executions2(i),'9,999,999,999')||' '||to_char(tab_buff_by_exec2(i),'999,999,999') ||to_char(tab_rows_processed2(i),'999,999,999') ||to_char(tab_disk_reads2(i),'999,999,999') ||to_char(tab_cpu_time2(i),'999,999,999') ||to_char(tab_elapsed_time2(i),'999,999,999,999') || '    | ');

      lv_sum1 := lv_sum1 + tab_buffer_gets1(i);
      lv_sum2 := lv_sum2 + tab_buffer_gets2(i);




   end loop;

   dbms_output.put_line ('...|.............................................................|.............................................................|');
   dbms_output.put_line ('Sum BuffGets P1:'||lv_sum1);
   dbms_output.put_line ('Sum BuffGets P2:'||lv_sum2);

   -- Show Text
   dbms_output.put_line ('TEXTS:');
   for i in 1..lv_top_n
   loop
      dbms_output.put_line (to_char(i,'09') || '  '||to_char(tab_hash1(i),'999999999999')||' '||tab_sqltext1(i));
      if (tab_hash1(i) <> tab_hash2(i)) then
         dbms_output.put_line (to_char(i,'09') || '* '||to_char(tab_hash2(i),'999999999999')||' '||tab_sqltext2(i));
      end if;
   end loop;

   dbms_output.put_line (chr(10) );
   dbms_output.put_line ('*****************************************');
   dbms_output.put_line ('Top '||lv_top_n_io||' IO datafiles');
   dbms_output.put_line ('*****************************************');
   dbms_output.put_line (chr(10) );

   open top_n_file_io (lv_snap1_ini, lv_snap1_fin, lv_dbid, lv_inst_num);
   fetch top_n_file_io bulk collect into tab_snapid1, tab_filename1, tab_total_io1, tab_total_block1;
   close top_n_file_io;
   --
   open top_n_file_io (lv_snap2_ini, lv_snap2_fin, lv_dbid, lv_inst_num);
   fetch top_n_file_io bulk collect into tab_snapid2, tab_filename2, tab_total_io2, tab_total_block2;
   close top_n_file_io;


   dbms_output.put_line ('........................... Periodo 1 ......................................|.......................... Periodo 2 .......................................|');
   dbms_output.put_line ('Filename                                             Total IOs  Total Blocks|Filename                                             Total IOs  Total Blocks|');
   dbms_output.put_line ('............................................................................|............................................................................|');

   for i in 1..lv_top_n_io
   loop
      dbms_output.put_line (rpad(substr(to_char(tab_filename1(i)),1,50),50,' ')||to_char(tab_total_io1(i),'999,999,999')||to_char(tab_total_block1(i),'999,999,999')||'  |'||
                            rpad(substr(to_char(tab_filename2(i)),1,50),50,' ')||to_char(tab_total_io2(i),'999,999,999')||to_char(tab_total_block2(i),'999,999,999')||'  |'    );
   end loop;

   dbms_output.put_line ('............................................................................|............................................................................|');

end;
/

set feed on;

Prompt End of report.
