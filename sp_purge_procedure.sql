create or replace procedure perfstat.clean_statspack as
	cursor c_snap is
		select snap_id
		from (select snap_id
	 	      from stats$snapshot
		      where snap_time < trunc(sysdate) - 60
		      order by snap_id) 
		where rownum < 240 
		order by snap_id;
begin     
    
    for r1 in c_snap loop

     	statspack.purge(i_begin_snap    => r1.snap_id, 
			i_end_snap         => r1.snap_id,
			i_snap_range      => false, 
			i_extended_purge  => false);

	dbms_output.put_line('Purged snapshot number = ' || to_char(r1.snap_id) );
	
    end loop;
end;
/

variable jobno number;
variable instno number;
begin
  select instance_number into :instno from v$instance;

  dbms_job.submit(:jobno, 'perfstat.clean_statspack;', trunc(sysdate+1), 'trunc(SYSDATE+1)', TRUE, :instno);
  commit;
end;
/

print jobno