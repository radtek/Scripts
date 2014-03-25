
prompt interval example:
prompt  				'(sysdate + 1)'  -- todo dia mesmo horá
prompt 					'trunc(sysdate + 1) + 8 / 24' -- todo dia ás 8 horas
prompt obs: dbms_jobs não mantém timezone
prompt plsqlcode example:
prompt 				'ss_content.SP_BACKUP_GALERIAS;'
prompt 				'scott.emppackage.give_raise(''JFEE'', 3000.00);' 

VARIABLE jobno NUMBER 
BEGIN
 	DBMS_JOB.SUBMIT(:jobno, 
 		&PLSQLCODE, 
 		SYSDATE, 
 		&INTERVAL, 
		false, 
		1); -- instance
 	COMMIT;
 END;
/
PRINT jobno





VARIABLE jobno NUMBER 
BEGIN
 	DBMS_JOB.SUBMIT(:jobno, 
 		'ss_content.SP_BACKUP_GALERIAS;', 
 		trunc(sysdate + 1) + 8 / 24, 
 		'trunc(sysdate + 1) + 8 / 24', 
		false, 
		1); -- instance
 	COMMIT;
 END;
/
PRINT jobno