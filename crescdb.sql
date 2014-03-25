break on report skip 1
compute avg of "Aloc(Mb)" on report
compute avg of "Usado(Mb)" on report
compute avg of "Cresc(Mb)" on report
col timestamp for a10
col segment_owner for a10
col segment_name for a25
col "Aloc(Mb)" for 99999999999
col "Usado(Mb)" for 99999999999
col "Cresc(Mb)" for 99999999999

select /*+ use_hash(s1 s2) */
	s1.run_id, 
	s1."timestamp",
	s1.aloc "Aloc(Mb)",	
	s1.usad "Usado(Mb)",
	s1.usad - s2.usad "Cresc(Mb)"
from (
	select
		run_id,
		max(s1.timestamp)	"timestamp",
		trunc(sum(s1.total_bytes)/1024/1024,2) aloc,
		trunc((sum(s1.total_bytes) - sum(s1.unused_bytes))/1024/1024,2) usad
	from imm_storage s1
	group by s1.run_id) s1,
	(
	select
		run_id,
		max(s2.timestamp)	"timestamp",
		trunc(sum(s2.total_bytes)/1024/1024,2) aloc,
		trunc((sum(s2.total_bytes) - sum(s2.unused_bytes))/1024/1024,2) usad
	from imm_storage s2
	group by s2.run_id) s2
where s1.run_id = s2.run_id(+) + 1
order by 1
/
clear computes
clear breaks
