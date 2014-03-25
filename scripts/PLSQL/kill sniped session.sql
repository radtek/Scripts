--> kill via SO ou via PLSQL(ideal)
#!/bin/sh
tmpfile=/tmp/tmp.$$
sqlplus system/manager <<EOF
spool $tmpfile
select p.spid from v\$process p,v\$session s
where s.paddr=p.addr
and s.status='SNIPED';
spool off
EOF
for x in `cat $tmpfile | grep "^[0123456789]"`
do
kill -9 $x
done
rm $tmpfile


VARIABLE jobno NUMBER 
BEGIN
 	DBMS_JOB.SUBMIT(:jobno, 
 		'DECLARE 
			v_stmt varchar2(2000);
		BEGIN 	
			FOR i in (SELECT sid, SERIAL# FROM v$session WHERE status = ''SNIPED'') LOOP
				v_stmt := ''ALTER SYSTEM DISCONNECT SESSION '''''' || to_char(i.sid) || '','' || to_char(i.serial#) || '''''' IMMEDIATE'';		
							
				INSERT INTO LOGS_KILL(sid, serial#, username, machine, status, logon_time, data)
				select sid, serial#, username, machine, status, logon_time, sysdate
				from v$session 
				where sid = i.SID
				  AND  username = ''IBOXNET''
				  AND serial# = i.serial#;
				
				execute immediate v_stmt;						
			END LOOP;
		END;', 
 		SYSDATE, 
 		'sysdate + 1 / 24 / 60 * 5'); 
 		COMMIT;
END;
/
PRINT jobno


BEGIN
   DBMS_JOB.CHANGE(62, 'DECLARE 
			v_stmt varchar2(2000);
		BEGIN 	
			FOR i in (SELECT sid, SERIAL# FROM v$session WHERE status = ''SNIPED'') LOOP
				v_stmt := ''ALTER SYSTEM DISCONNECT SESSION '''''' || to_char(i.sid) || '','' || to_char(i.serial#) || '''''' IMMEDIATE'';		
							
				INSERT INTO LOGS_KILL_JOB_62(sid, serial#, username, machine, status, logon_time, data)
				select sid, serial#, username, machine, status, logon_time, sysdate
				from v$session 
				where sid = i.SID
				  AND serial# = i.serial#;
				 			
				
				execute immediate v_stmt;						
			END LOOP;
			commit;
		END;', 
		null, 'sysdate + 1 / 24 / 60 * 15');
   COMMIT;
END; 
/