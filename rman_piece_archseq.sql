select handle, tag, completion_time, round(bytes/1024/1024) as MB
from v$backup_piece  where recid  in(
	select BP_KEY from v$backup_piece_details where BS_KEY in(
		select btype_key from v$backup_archivelog_details where sequence#=&sequence and thread#=&thread)
	)
order by 4;
