prompt ex: suporte de 300 IO/sec e 10 ms response time:
prompt 		Max IOPS=299
prompt 		Max MBps=87
prompt 		Latency =9
prompt 		
DECLARE
	v_max_iops NUMBER;
	v_max_mbps NUMBER;
	v_actual_latency NUMBER;
BEGIN
	DBMS_RESOURCE_MANAGER.calibrate_io(
		num_physical_disks => 4,
		max_latency => 10,
		max_iops => v_max_iops,
		max_mbps => v_max_mbps,
		actual_latency => v_actual_latency);

	DBMS_OUTPUT.put_line('Max IOPS=' || v_max_iops);
	DBMS_OUTPUT.put_line('Max MBps=' || v_max_mbps);
	DBMS_OUTPUT.put_line('Latency =' || v_actual_latency);
END;
/