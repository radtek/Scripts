
accept dt1_ini prompt          'Start Time (1) (dd/mm/yyyy hh24:mi:ss):'
accept dt1_fin prompt          'End   Time (1) (dd/mm/yyyy hh24:mi:ss):'
accept instance_number prompt  'Instance Number ?.....................:'
accept top_n    Prompt         'Top N ?...............................:'

set serveroutput on size 1000000;
set feed off;
declare
   lv_dt1_ini date := to_date('&dt1_ini','dd/mm/yyyy hh24:mi:ss');
   lv_dt1_fin date := to_date('&dt1_fin','dd/mm/yyyy hh24:mi:ss');
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


   --
   type typ_string is table of varchar2(100);
   type typ_number is table of number;
   --
   tab_event1  typ_string;
   tab_waits1  typ_number;
   tab_time1   typ_number;
   tab_pcttot1 typ_number;
   --
   tab_hash1           typ_string;
   tab_sqltext1        typ_string;
   tab_buffer_gets1    typ_number;
   tab_executions1     typ_number;
   tab_disk_reads1     typ_number;
   tab_buff_by_exec1   typ_number;
   --
   tab_snapid1        typ_number;
   tab_filename1       typ_string;
   tab_total_io1       typ_number;
   tab_total_block1    typ_number;
   --
   lv_signal           varchar2(1);
   lv_dummy			   number;
begin
   --
   dbms_output.put_line (chr(10) || chr(10));
   dbms_output.put_line ('**************************************');
   dbms_output.put_line ('Comparação de estatístias do AWR......');
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
   open get_snap_info (lv_snap1_ini, lv_snap1_fin);
   fetch get_snap_info into lv_snap_time1_ini, lv_snap_time1_fin;
   close get_snap_info;
   if (lv_snap_time1_ini is null or lv_snap_time1_fin is null) then
      raise_application_error (-20003,'Existe um startup entre o intervalo:' ||
                                      to_char(lv_dt1_ini,'dd/mm/yyyy hh24:mi:ss') || ' a ' ||
                                      to_char(lv_dt1_fin,'dd/mm/yyyy hh24:mi:ss'));
   end if;
   --
   lv_elapse1_seconds := round((lv_snap_time1_fin - lv_snap_time1_ini) * 24 * 60 * 60);
   --
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
   dbms_output.put_line ('...|....................... Periodo 1 ............................|');
   dbms_output.put_line ('Top| Event                              Waits            Time(cs) |');
   dbms_output.put_line ('...|..............................................................|');
   --
   for i in 1..lv_top_n
   loop
      lv_signal := ' ';
      dbms_output.put_line (to_char(i,'09') || lv_signal ||'| ' ||rpad(tab_event1(i),25,' ') ||' '||to_char(tab_waits1(i),'9,999,999,999')||' '||to_char(tab_time1(i),'99,999,999,999,999')||' | ');
   end loop;
   dbms_output.put_line ('...|..............................................................|');

   --
end;
/

set feed on;

Prompt End of report.
