Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'

col disk format a50
break on disk skip 1 

SELECT   
		 snap_id,
		 disk,
         to_char(begin_interval_time,'DD/MM/YYYY HH24:MI') snap_start_time,		
         SUM(phyrds_delta + phywrts_delta) IOs,
		 round(SUM(phyrdsBytes_delta + phywrtsBytes_delta)/ 1024 / 1024) ThroughputMB,		 
         MAX(NVL (ROUND (1000 * readtime_delta / NULLIF (phyrds_delta, 0), 2), 0) + 
			 NVL (ROUND (1000 * writetime_delta / NULLIF (phywrts_delta, 0), 2), 0)) time_per_IO_ms,          		 
         MAX(NVL (ROUND (1000 * wait_time_delta / NULLIF (phyrds_delta, 0), 2), 0) + 
			NVL (ROUND (1000 * wait_time_delta / NULLIF (phywrts_delta, 0), 2), 0)) waits_per_IO_ms
FROM     (SELECT snap_id,
                 begin_interval_time,
				 INSTANCE_NUMBER,
                 disk,                 
                 readtime - LAG (readtime) OVER (ORDER BY disk,instance_number, snap_id) readtime_delta,
				 writetime - LAG (writetime) OVER (ORDER BY disk,instance_number, snap_id) writetime_delta,
				 phyrds - LAG (phyrds) OVER (ORDER BY disk,instance_number, snap_id) phyrds_delta,
                 phywrts - LAG (phywrts) OVER (ORDER BY disk,instance_number, snap_id) phywrts_delta,                 				 
				 phyrdsBytes - LAG (phyrdsBytes) OVER (ORDER BY disk,instance_number, snap_id) phyrdsBytes_delta,
                 phywrtsBytes - LAG (phywrtsBytes) OVER (ORDER BY disk,instance_number, snap_id) phywrtsBytes_delta,                 				 
                 wait_count - LAG (wait_count) OVER (ORDER BY disk,instance_number, snap_id) wait_count_delta,
                 wait_time - LAG (wait_time) OVER (ORDER BY disk,instance_number, snap_id) wait_time_delta
          FROM   (SELECT   fs.snap_id,
                           snap.begin_interval_time,
						   fs.INSTANCE_NUMBER,
                           substr(FILENAME, 1, instr(FILENAME, '/') - 1) disk,
                           SUM (fs.readtim) / 100 readtime,
                           SUM (fs.writetim) / 100 writetime,
                           SUM (fs.phyrds) phyrds,
                           SUM (fs.phywrts) phywrts,
						   SUM (fs.phyBLKrd * fs.block_size) phyrdsBytes,
                           SUM (fs.phyBLKwrt * fs.block_size) phywrtsBytes,
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
                                                        AND TO_DATE ('&dt2', 'DD-MM-YYYY HH24:MI:SS')
				  AND  (fs.phyrds !=0 and fs.phywrts!=0)
                  GROUP BY fs.snap_id,
                           snap.begin_interval_time,
                           substr(FILENAME, 1, instr(FILENAME, '/') - 1),
						   fs.INSTANCE_NUMBER))
WHERE    begin_interval_time BETWEEN TO_DATE ('&dt1', 'DD-MM-YYYY HH24:MI:SS') 
		  					  AND TO_DATE ('&dt2', 'DD-MM-YYYY HH24:MI:SS')
GROUP BY disk,							  
		 snap_id,
		 to_char(begin_interval_time,'DD/MM/YYYY HH24:MI')
ORDER BY disk, 
		 snap_id,
		 snap_start_time;		 

undef dt1
undef dt2