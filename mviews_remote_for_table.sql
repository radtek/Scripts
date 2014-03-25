define table_name=&table_name

COLUMN snapshot_id HEADING 'SnapshotID' FORMAT b9999999999
COLUMN owner HEADING 'Owner' FORMAT A6
COLUMN name HEADING 'Mview Name' FORMAT A30
COLUMN snapshot_site HEADING 'Mview Site' format a30
COLUMN current_snapshots HEADING 'Last Time Refresh' format a21 

select l.snapshot_id, owner, name, substr(snapshot_site,1,30) snapshot_site, 
to_char(current_snapshots, 'mm/dd/yyyy hh24:mi:ss') current_snapshots
from dba_registered_snapshots r, dba_snapshot_logs l
where r.snapshot_id = l.snapshot_id (+)
and l.master=upper('&table_name');


select * 
from dba_registered_snapshots 
where name like upper('%&table_name%');


undef table_name