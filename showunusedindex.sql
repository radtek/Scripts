   column index_name format a12
   column monitoring format a10
   column used format a4
   column start_monitoring format a19
   column end_monitoring format a19
   column PK format a19
   column UK format a19
   column FK format a19
    
   select d.owner, 
		d.table_name, 
		v.index_name,
		v.monitoring,
		v.start_monitoring,
		v.end_monitoring, 
		v.used,
		DECODE(c.constraint_type, 'P', 'PK', '') as PK, 
		DECODE(c.constraint_type, 'U', 'UK', '') as UK, 
		COALESCE(ci.constraint_name, '') as FK 
   from v$object_usage v
		inner join dba_indexes d
			on v.index_name = d.name
			and d.owner not in ('SYS','SYSTEM')
		left join dba_constraints c
			on c.index_name = d.name
			and c.constraint_type IN ('P', 'U')
		left join ( select ci.constraint_name
					from dba_ind_columns ic
						 inner join dba_cons_columns ci
							on ic.table_name = ci.table_name
							and ic.column_name = ci.column_name
					where ic.column_position=1
					  and ci.position = 1
					  and ic.index_owner not in ('SYSTEM', 'SYS') ) CI
			on CI.index_owner = d.owner
			and CI.index_name = d.name;
		

			