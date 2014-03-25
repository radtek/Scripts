prompt deve executar com o sys
SELECT instance_number, 
		host_name, 
		instance_name,
		name_ksxpia network_interface, 
		ip_ksxpia private_ip
 FROM x$ksxpia
	CROSS JOIN v$instance
 WHERE pub_ksxpia = 'N';