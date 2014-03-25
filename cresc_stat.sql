Accept r1 Prompt 'Run_id Ini:'
Accept r2 Prompt 'Run_id Fin:'

Prompt By database....

Select s1.time_stamp dt_ini,
       s2.time_stamp dt_fin,
       round(s2.time_stamp - s1.time_stamp) num_days,
       s1.alloc_mb alloc_ini,
       s2.alloc_mb allo_fin,
       s2.alloc_mb - s1.alloc_mb alloc_cres,
       s1.Used_mb used_ini,
       s2.Used_mb used_fin,
       s2.Used_mb - s1.Used_mb used_cresc
  from (Select Max(timestamp) time_stamp,
               Round(Sum(total_bytes)/1024/1024) alloc_mb,
	           Round(Sum(total_bytes - unused_bytes)/1024/1024) Used_Mb
	      from system.imm_storage
	     where run_id = &r1
       ) s1,
       (Select Max(timestamp) time_stamp,
	           Round(Sum(total_bytes)/1024/1024) alloc_mb,
	           Round(Sum(total_bytes - unused_bytes)/1024/1024) Used_Mb
	      from system.imm_storage
	     where run_id = &r2
       ) s2
/

Prompt by Schemas...

Select s1.time_stamp dt_ini,
       s2.time_stamp dt_fin,
       round(nvl(s2.time_stamp, sysdate) - nvl(s1.time_stamp, sysdate)) num_days,
       nvl(s1.segment_owner, s2.segment_owner) segment_owner,
       s1.alloc_mb alloc_ini,
       s2.alloc_mb allo_fin,
       nvl(s2.alloc_mb,0) - nvl(s1.alloc_mb,0) alloc_cres,
       s1.Used_mb used_ini,
       s2.Used_mb used_fin,
       nvl(s2.Used_mb,0) - nvl(s1.Used_mb,0) used_cresc
  from (Select Segment_owner,
               Max(timestamp) time_stamp,
               Round(Sum(total_bytes)/1024/1024) alloc_mb,
	           Round(Sum(total_bytes - unused_bytes)/1024/1024) Used_Mb
	      from system.imm_storage
	     where run_id = &r1
		 Group by Segment_owner
       ) s1
       full join (Select Segment_owner,
	           Max(timestamp) time_stamp,
	           Round(Sum(total_bytes)/1024/1024) alloc_mb,
	           Round(Sum(total_bytes - unused_bytes)/1024/1024) Used_Mb
	      from system.imm_storage
	     where run_id = &r2
		 Group by Segment_owner
       ) s2
       on S1.segment_owner = S2.segment_owner
 Order by used_cresc desc
/


Prompt by Top Table segment...

Select * from (
Select s1.time_stamp dt_ini,
       s2.time_stamp dt_fin,
       round(nvl(s2.time_stamp,sysdate) - nvl(s1.time_stamp, sysdate)) num_days,
       nvl(s1.segment_owner, s2.segment_owner) segment_owner,
       nvl(s1.segment_name, s2.segment_name) Table_name,
       s1.alloc_mb alloc_ini,
       s2.alloc_mb allo_fin,
       nvl(s2.alloc_mb,0) - nvl(s1.alloc_mb,0) alloc_cres,
       s1.Used_mb used_ini,
       s2.Used_mb used_fin,
       nvl(s2.Used_mb,0) - nvl(s1.Used_mb,0) used_cresc
  from (Select Segment_owner, segment_name,
               Max(timestamp) time_stamp,
               Round(Sum(total_bytes)/1024/1024) alloc_mb,
	           Round(Sum(total_bytes - unused_bytes)/1024/1024) Used_Mb
	      from system.imm_storage
	     where run_id = &r1
		   and segment_type like 'TABLE%'
		 Group by Segment_owner, segment_name
       ) s1
       full join (Select Segment_owner,segment_name,
	           Max(timestamp) time_stamp,
	           Round(Sum(total_bytes)/1024/1024) alloc_mb,
	           Round(Sum(total_bytes - unused_bytes)/1024/1024) Used_Mb
	      from system.imm_storage
	     where run_id = &r2
		   and segment_type like 'TABLE%'
		 Group by Segment_owner, segment_name
       ) s2
	ON S1.segment_owner = S2.segment_owner
	and S1.segment_name  = S2.segment_name
 Order by used_cresc desc)
 Where rownum <= 08
/
