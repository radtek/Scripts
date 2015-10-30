
create procedure sys.clean_statspack_ilegra as
	min_date date;
	lo_snap number(5);
	hi_snap number(5);
begin
	select min(snap_time) into min_date from stats$snapshot;
	select min(snap_id) into lo_snap from stats$snapshot;
	select max(snap_id) into hi_snap from stats$snapshot where snap_time < min_date+1;
statspack.purge(i_begin_snap    => lo_snap
           , i_end_snap         => hi_snap
            , i_snap_range      => true
            , i_extended_purge  => false
            , i_dbid            => <dbid do banco>
            , i_instance_number => 1);
end;
/
