prompt interval example:
prompt  				'(sysdate + 1)'  -- todo dia mesmo hor�
prompt 					'trunc(sysdate + 1) + 8 / 24' -- todo dia �s 8 horas
prompt obs: dbms_jobs n�o mant�m timezone
prompt plsqlcode example:
prompt 				'ss_content.SP_BACKUP_GALERIAS;'
prompt 				'scott.emppackage.give_raise(''JFEE'', 3000.00);' 


BEGIN
   DBMS_JOB.CHANGE(&jobno, &plsqlcode, null, 'sysdate+3');
   COMMIT;
END; 
/