
undef owner
undef segmentname
define owner=&owner
define segmentname=&segmentname

select u.username as owner, round(coalesce(sum(s.bytes)/1024/1024, 0)) MB
from dba_users u
	 left join dba_segments s
		on u.username = s.owner	
where s.owner like upper('&owner')
  and s.segment_name like upper('&segmentname')
group by u.username
order by u.username;
undef owner
undef segmentname