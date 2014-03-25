SELECT t.name template_name, 
		t.SYSTEM, 
		t.redundancy,
		t.stripe, 
		t.primary_region
FROM v$asm_template t
		JOIN v$asm_diskgroup d
			ON (d.group_number = t.group_number)
WHERE d.name = '&dgname'
ORDER BY t.name;