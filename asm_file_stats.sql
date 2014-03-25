SELECT rootname,
	d.name diskgroup_name,
	f.TYPE, 
	a.name filename,
	space / 1048576 allocated_mb, 
	primary_region, 
	striped,
    round((hot_reads + hot_writes)/1000,2) hot_ios1k,
    round((cold_reads + cold_writes)/1000,2) cold_ios1k
FROM (SELECT CONNECT_BY_ISLEAF, 
			group_number, 
			file_number, 
			name,
			CONNECT_BY_ROOT name rootname, 
			reference_index,
			parent_index
	  FROM v$asm_alias a
	  CONNECT BY PRIOR reference_index = parent_index) a
	JOIN (SELECT DISTINCT name
		   FROM v$asm_alias
			 /* top 8 bits of the parent_index is the group_number, so
			 the following selects aliases whose parent is the group
			 itself - eg top level directories within the disk group*/
		   WHERE parent_index = group_number * POWER(2, 24)) b
			ON (a.rootname = b.name)
	JOIN v$asm_file f
		ON (a.group_number = f.group_number
		AND a.file_number = f.file_number)
	JOIN v$asm_diskgroup d
		ON (f.group_number = d.group_number)
 WHERE a.CONNECT_BY_ISLEAF = 1
 ORDER BY (cold_reads+cold_writes+hot_reads+hot_writes) DESC;