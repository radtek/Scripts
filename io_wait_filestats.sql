prompt 10g considera statisticas desde restart
prompt 
with filestat as
(
SELECT tablespace_name, 
	phyrds, 
	phywrts, 
	phyblkrd, 
	phyblkwrt,
	singleblkrds, 
	readtim, 
	writetim, 
	singleblkrdtim
 FROM v$tempstat 
	JOIN dba_temp_files
		ON (file# = file_id)
 UNION
 SELECT tablespace_name, 
	phyrds, 
	phywrts, 
	phyblkrd, 
	phyblkwrt,
	singleblkrds, 
	readtim, 
	writetim, 
	singleblkrdtim
 FROM v$filestat 
	JOIN dba_data_files
		ON (file# = file_id)
)
 SELECT tablespace_name, 
	ROUND(SUM(phyrds) / 1000) phyrds_1000,
	ROUND(SUM(phyblkrd) / SUM(phyrds)) avg_blk_reads,
	ROUND((SUM(readtim) + SUM(writetim)) / 100 / 3600,2) iotime_hrs,
	ROUND(SUM(phyrds + phywrts) * 100 / SUM(SUM(phyrds + phywrts)) OVER (), 2) pct_io, ROUND(SUM(phywrts) / 1000) phywrts_1000,
	ROUND(SUM(singleblkrdtim) * 10 / SUM(singleblkrds), 2) single_rd_avg_time
 FROM filestat
 GROUP BY tablespace_name
 ORDER BY (SUM(readtim) + SUM(writetim)) DESC;