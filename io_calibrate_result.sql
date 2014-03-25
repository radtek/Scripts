SELECT max_iops, 
	max_mbps, 
	max_pmbps, 
	latency,
	num_physical_disks
FROM dba_rsrc_io_calibrate;