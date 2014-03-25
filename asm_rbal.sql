SELECT 		dg.group_number, 
		dg.NAME, 
		d.operation, 
		d.state, 
		d.POWER, 
		d.actual, 
		est_work ,
		d.sofar*100/d.est_work pct_done, 
		d.est_rate, 
		d.est_minutes
FROM v$asm_diskgroup dg 
	LEFT OUTER JOIN gv$asm_operation d
ON (d.group_number = dg.group_number);