set serveroutput on 
@@act9i_dimedweb

DECLARE 
	v_stmt varchar2(2000);
begin    
   FOR i in (select 'alter system kill session '||''''||sid||','||serial#||''''||';' as sql 
			 from v$session
			 where username = upper('DIMEDWEB')
			 order by logon_time) LOOP

		v_stmt:= i.SQL;
		
		dbms_output.put_line(v_stmt);
							
		execute immediate v_stmt;						

   END LOOP;
end;
/

@@act9i_dimedweb

SELECT 'EXECUTE SYS.dbms_system.set_ev (' || TO_CHAR (sid) ||
          ', ' || TO_CHAR (serial#) || ', 10046, 8, '''');' || chr(13) || chr(10) ||
   'EXECUTE SYS.dbms_system.set_ev (' || TO_CHAR (sid) ||
          ', ' || TO_CHAR (serial#) || ', 10046, 0, '''');'
FROM   v$session
WHERE  username = UPPER('DIMEDWEB')
and status <> 'KILLED'
order by logon_time;
