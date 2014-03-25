Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'

col disk for a100
select * 
from 
	(SELECT   
			 to_char(begin_interval_time,'DD/MM/YYYY HH24:MI') snap_start_time,
			 INSTANCE_NUMBER,
			 disk,
			 phyrds_delta + phywrts_delta io_delta,
			 phyrds_delta READS,
			 phywrts_delta wrts,
			 NVL (ROUND (1000 * readtime_delta / NULLIF (phyrds_delta, 0), 2), 0) time_per_read_ms,
			 NVL (ROUND (1000 * writetime_delta / NULLIF (phywrts_delta, 0), 2), 0) time_per_write_ms,
			 NVL (ROUND (1000 * wait_time_delta / NULLIF (phyrds_delta, 0), 2), 0) waits_per_read_ms
	FROM     (SELECT snap_id,
					 begin_interval_time,
					 INSTANCE_NUMBER,
					 disk,
					 phyrds - LAG (phyrds) OVER (ORDER BY disk,instance_number, snap_id) phyrds_delta,
					 readtime - LAG (readtime) OVER (ORDER BY disk,instance_number, snap_id) readtime_delta,
					 phywrts - LAG (phywrts) OVER (ORDER BY disk,instance_number, snap_id) phywrts_delta,
					 writetime - LAG (writetime) OVER (ORDER BY disk,instance_number, snap_id) writetime_delta,
					 wait_count - LAG (wait_count) OVER (ORDER BY disk,instance_number, snap_id) wait_count_delta,
					 wait_time - LAG (wait_time) OVER (ORDER BY disk,instance_number, snap_id) wait_time_delta
			  FROM   (SELECT   fs.snap_id,
							   snap.begin_interval_time,
							   fs.INSTANCE_NUMBER,
							   FILENAME  as disk,
							   SUM (fs.readtim) / 100 readtime,
							   SUM (fs.writetim) / 100 writetime,
							   SUM (fs.phyrds) phyrds,
							   SUM (fs.phywrts) phywrts,
							   SUM (fs.wait_count) wait_count,
							   SUM (fs.TIME) / 100 wait_time
					  FROM     (SELECT *
								FROM   dba_hist_filestatxs
								union all
								SELECT *
								FROM   dba_hist_tempstatxs) fs,
							   dba_hist_snapshot snap
					  WHERE    snap.snap_id = fs.snap_id
					  and fs.INSTANCE_NUMBER = snap.INSTANCE_NUMBER
					  AND      snap.begin_interval_time BETWEEN TO_DATE ('&dt1', 'DD-MM-YYYY HH24:MI:SS')
															AND TO_DATE ('16-10-2012 12:00:00', 'DD-MM-YYYY HH24:MI:SS')
					  AND  (fs.phyrds !=0 and fs.phywrts!=0)
					  GROUP BY fs.snap_id,
							   snap.begin_interval_time,
							   FILENAME,
							   fs.INSTANCE_NUMBER))
	WHERE    begin_interval_time BETWEEN TO_DATE ('&dt1', 'DD-MM-YYYY HH24:MI:SS') 
								  AND TO_DATE ('16-10-2012 12:00:00', 'DD-MM-YYYY HH24:MI:SS')							  							 
	ORDER BY 
			time_per_read_ms + time_per_write_ms desc,
			disk, 
			instance_number,
			snap_id ASC, 
			snap_start_time)		 
where rownum < 100
order by time_per_read_ms + time_per_write_ms desc;

undef dt1
undef dt2
