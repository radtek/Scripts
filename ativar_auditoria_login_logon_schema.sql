whenever SQLerror exit failure;
select aaaa///

CREATE TABLE SYSTEM.LOGIN_TRIGGER
	( 
		 user_name VARCHAR2(4000) 
		,ddl_date timestamp
		,host_name varchar2(100)	
		,instance varchar2(10)
		,ip_address varchar2(20)
	)
tablespace auditoria; 	

grant insert on SYSTEM.LOGIN_TRIGGER to public;


create or replace trigger system.TRG_AUDIT_LOGING
AFTER LOGON ON DATABASE
BEGIN
	insert into SYSTEM.LOGIN_TRIGGER ( user_name,ddl_date,host_name,instance,ip_address ) 
	values(ora_login_user ,systimestamp ,SYS_CONTEXT('USERENV','HOST'),SYS_CONTEXT('USERENV','INSTANCE'),SYS_CONTEXT('USERENV','IP_ADDRESS'));
	    
	commit;	
END; 
/

ou 

--> ignorando algum owner:
CREATE OR REPLACE TRIGGER "SYSTEM"."TRG_AUDIT_LOGING"
AFTER LOGON ON DATABASE
BEGIN
        IF (ora_login_user <> 'MERCURYBRMOC' AND ora_login_user <> 'ATMAILBRMOC' and
                ora_login_user <> 'MERCURYLATAM' AND ora_login_user <> 'ATMAIL') THEN
        insert into SYSTEM.LOGIN_TRIGGER ( user_name,ddl_date,host_name,instance,ip_address )
        values(ora_login_user ,systimestamp ,SYS_CONTEXT('USERENV','HOST'),SYS_CONTEXT('USERENV','INSTANCE'),SYS_CONTEXT('USERENV','IP_ADDRESS'));
        commit;
        END IF;
END;

16:45:19 miamidb>select count(1) from SYSTEM.LOGIN_TRIGGER;

  COUNT(1)
----------
       238

1 linha selecionada.


Teste:
	select count(1), user_name, max(ddl_date) - min(ddl_date) from SYSTEM.LOGIN_TRIGGER group by user_name order by 1 desc;
	  COUNT(1) USER_NAME                      MAX(DDL_DATE)-MIN(DDL_DATE)
	---------- ------------------------------ ------------------------------------------------
			 3 MAIL                           +000000000 00:00:03.801179
			 1 BRIDGE_ACCT                    +000000000 00:00:00.000000
Pendências:
	-> DROP TABLE SYSTEM.LOGIN_TRIGGER;
	-> DROP trigger system.TRG_AUDIT_LOGING;
	-> DROP TABLESPACE AUDITORIA INCLUDING CONTENTS AND DATAFILES: