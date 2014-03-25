	ALTER TABLE vgnjobitemorder SHRINK SPACE COMPACT;  -- reorganiza blocos, não gera lock, valido para index/table, mesmo que COALESCE
	ALTER TABLE vgnjobitemorder SHRINK SPACE; -- move HW, gerar cursores invalidos, gera lock

declare
	vsql varchar2(4000);
	cursor cr is 
		select table_name 
		from dba_tables 
		where owner = 'VCMSYS';	
begin 
	for rec in cr loop
		begin 
			dbms_output.put_line(rec.table_name);

			vsql:='ALTER TABLE VCMSYS.' ||rec.table_name || '  ENABLE ROW MOVEMENT';
			execute immediate(vsql);

			vsql:='ALTER TABLE VCMSYS.' ||rec.table_name || '  SHRINK SPACE COMPACT';
			execute immediate(vsql);

			vsql:='ALTER TABLE VCMSYS.' ||rec.table_name || '  SHRINK SPACE';
			execute immediate(vsql);

			vsql:='ALTER TABLE VCMSYS.' ||rec.table_name || '  DISABLE ROW MOVEMENT';
			execute immediate(vsql);
		exception 
			when others then 
			begin
				vsql:='ALTER TABLE VCMSYS.' ||rec.table_name || '  DISABLE ROW MOVEMENT';
				execute immediate(vsql);
			end;
		end;
	end loop;
end;
/

declare
	vsql varchar2(4000);
	cursor cr is 
		select index_name 
		from dba_indexes
		where owner = 'VCMSYS'
		order by index_name;	
begin 
	for rec in cr loop
			dbms_output.put_line(rec.index_name);

			vsql:='ALTER INDEX VCMSYS.' ||rec.index_name || '  SHRINK SPACE COMPACT';
			execute immediate(vsql);

			vsql:='ALTER INDEX VCMSYS.' ||rec.index_name || '  SHRINK SPACE';
			execute immediate(vsql);
	end loop;
end;
/