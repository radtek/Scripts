 CREATE TABLE "SYSTEM"."LOGS_KILL"
  (    "SID" NUMBER,
       "SERIAL#" NUMBER,
       "MACHINE" VARCHAR2(64),
       "LOGON_TIME" DATE,
       "PREV_SQL_ID" VARCHAR2(13),
       "DATA" DATE
  ) 
 TABLESPACE "USERS";
 
--> kill via SO ou via PLSQL(ideal)
VARIABLE jobno NUMBER 
BEGIN
 	DBMS_JOB.SUBMIT(:jobno, 
 		'DECLARE 
			v_stmt varchar2(2000);
		BEGIN 	
			FOR i in (select s.sid, s.serial#, s.machine, s.logon_time, s.prev_sql_id from v$session s where s.username = ''MUSA_BASE'' and s.wait_class = ''Idle'' and (s.last_call_et / 60) > 5 and exists(select 1 from v$lock l where l.type = ''UL'' and l.lmode=6 and l.request=0 and l.sid = s.sid)) LOOP
				
				v_stmt := ''ALTER SYSTEM KILL SESSION '''''' || to_char(i.sid) || '','' || to_char(i.serial#) || '''''' IMMEDIATE'';		
							
				INSERT INTO SYSTEM.LOGS_KILL(sid, serial#, machine, logon_time, prev_sql_id, data)
				values(i.sid, i.serial#, i.machine, i.logon_time, i.prev_sql_id, sysdate);							
				
				execute immediate v_stmt;
			END LOOP;
		END;', 
 		SYSDATE, 
 		'sysdate + 1 / 24 / 60 * 5'); 
 		COMMIT;
END;
/
PRINT jobno
