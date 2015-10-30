
declare
	vsql varchar2(4000);
	
	cursor cr_index(v_table_name VARCHAR2) is 
		select index_name 
		from dba_indexes
		where owner = 'VCMLIVE'
		and table_name = v_table_name
		order by index_name;	
		
	cursor cr_table is 
		select table_name 
		from dba_tables
		where owner = 'VCMLIVE'
		order by table_name;	
begin 
	for rec_table in cr_table loop
				dbms_output.put_line(rec_table.table_name);				
				for rec_index in cr_index(rec_table.table_name) loop			
					--vsql:='ALTER INDEX VCMSYS.' ||rec.index_name || '  SHRINK SPACE COMPACT';
					--execute immediate(vsql);
					dbms_output.put_line(rec_index.index_name);
				end loop;						
	end loop;
end;
/