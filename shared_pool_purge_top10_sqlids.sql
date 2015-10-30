declare 
	vsql varchar2(4000);
	vcount binary_integer;
begin 
	for c1 in (select distinct S.sql_id, trim(cast(S.ADDRESS as char(100))) as ADDRESS, trim(to_char(S.HASH_VALUE)) hash_value 
				from V$SQL S,
					 (select /*+ no_merge*/ sql_id 
					  from (select count(1) ctd, sql_id 	
							from v$sql 
							group by sql_id 
							having count(1) > 20
							order by ctd desc) 
					  where rownum < 10) T
				where S.SQL_ID = T.sql_id)
	loop
		
		vsql:= 'begin sys.DBMS_SHARED_POOL.PURGE (''' || c1.ADDRESS || ',' || c1.HASH_VALUE || ''', ''C''); end;' ;
					
		dbms_output.put_line(vsql);
		execute immediate vsql;
		
		--- validar se conseguiu remover
		select count(1)
		into vcount
		from v$sql 
		where sql_id = c1.sql_id;
		
		if (vcount = 0 ) then
			dbms_output.put_line('SQL_ID=' || to_char(c1.sql_id) || ' - OK');
		else 
			dbms_output.put_line('*********');
			dbms_output.put_line('SQL_ID=' || to_char(c1.sql_id) || ' - NAO REMOVIDO DO CACHE!!!');
			dbms_output.put_line(vsql);
			dbms_output.put_line('*********');
		end if;		
		
	end loop;
end;