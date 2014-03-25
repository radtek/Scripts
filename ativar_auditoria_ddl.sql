buenas, 

Auditoria ativada via database trigger, pois via comando audit aumenta muito a complexidade no nosso caso que vamos monitorar todos os tipos de DDL possiveis:

-> Fonte:
	How To Capture All The DDL Statements [ID 739604.1]

	Change log:
		Adicionado as colunas:
		- host_name
		- instance 
		- ip_address 

-> requisitos:
	parametro precisa estar como true (já estava):
	SQL> show parameter system 

	NAME TYPE VALUE 
	------------------------------------ ----------- ------ 
	_system_trig_enabled boolean TRUE 


-> Procedimento:
	CREATE TABLE SYSTEM.DDL_ACTIONS 
	( 
		counter number(38) 
		,user_name VARCHAR2(4000) 
		,ddl_date timestamp
		,ddl_type VARCHAR2(4000) 
		,object_type VARCHAR2(4000) 
		,owner VARCHAR2(4000) 
		,object_name VARCHAR2(4000) 
		,sqltext CLOB 
		,host_name varchar2(100)
		,instance varchar2(10)
		,ip_address varchar2(20)
	); 	

		
create or replace trigger system.DDLTrigger 
AFTER DDL ON DATABASE 
declare 
	l_cnt BINARY_INTEGER := 0; 
	l_len integer := 0; 
	l_no integer := 1; 
	l_s varchar2(32767) := ''; 
	l_sql_text ora_name_list_t; 
BEGIN
	l_cnt :=  nvl(ora_sql_txt(l_sql_text),0); 
	
	for i in 1..l_cnt 
	loop 
		if l_cnt = 1 
		then 
			insert into system.DDL_ACTIONS ( counter ,user_name ,ddl_date ,ddl_type ,object_type ,owner 
				,object_name ,sqltext, host_name,instance,ip_address) 
			VALUES( i ,ora_login_user ,systimestamp ,ora_sysevent 
				,ora_dict_obj_type ,ora_dict_obj_owner ,ora_dict_obj_name ,l_sql_text(i), 
				SYS_CONTEXT('USERENV','HOST'),SYS_CONTEXT('USERENV','INSTANCE'),SYS_CONTEXT('USERENV','IP_ADDRESS')); 
		else 
			if l_len + length(l_sql_text(i)) > 32767 
			then 
				insert into system.DDL_ACTIONS ( counter ,user_name ,ddl_date ,ddl_type ,object_type ,owner 
					,object_name ,sqltext, host_name,instance,ip_address) 
				VALUES ( l_no ,ora_login_user ,systimestamp,ora_sysevent ,
					ora_dict_obj_type ,ora_dict_obj_owner ,ora_dict_obj_name ,l_s,
					SYS_CONTEXT('USERENV','HOST'),SYS_CONTEXT('USERENV','INSTANCE'),SYS_CONTEXT('USERENV','IP_ADDRESS')); 

				l_len := length(l_sql_text(i)); 
				l_s := l_sql_text(i); 
				l_no := l_no + 1; 
			else 			
				l_s := l_s||l_sql_text(i); 
				l_len := l_len + length(l_sql_text(i)); 
			end if; 
		end if; 
	end loop; 
	
	if l_s != '' 
	then 
		insert into system.DDL_ACTIONS ( counter ,user_name ,ddl_date ,ddl_type ,object_type ,owner 
					,object_name ,sqltext, host_name,instance,ip_address) 
		VALUES ( l_no ,ora_login_user ,systimestamp,ora_sysevent 
			,ora_dict_obj_type ,ora_dict_obj_owner ,ora_dict_obj_name ,l_s, 
			SYS_CONTEXT('USERENV','HOST'),SYS_CONTEXT('USERENV','INSTANCE'),SYS_CONTEXT('USERENV','IP_ADDRESS')); 
	end if; 
END; 
/

-> jobs agendado para executar todo dia 22:00
	-> Retenção de 60 dias
	-> audita DDLs em geral 

16:33:40 orausdw_2>@dbajobs
informe job=0 para todos
Informe o valor para job: 121
antigo   3: where job = &job or &job = 0
novo   3: where job = 121 or 121 = 0

       JOB SCHEMA_USE LOG_USER   NEXT_DATE           NEXT_SEC                           FAILURES B LAST_DATE           LAST_SEC                         INTERVAL
---------- ---------- ---------- ------------------- -------------------------------- ---------- - ------------------- -------------------------------- ------------------------------
       121 SYSTEM     SYSTEM     22/05/2012 22:00:00 22:00:00                                  0 N 22/05/2012 15:33:32 15:33:32                         trunc(sysdate) + 22 * (1 / 24)

1 linha selecionada.




-> para consultar:
set lines 2000
col user_name for a20
col object_type for a20
col owner for a20
col object_name for a30
col sql_text for a100 wrapped
col hostname for a20
col instance for a5
col ip_address for a20
col ddl_type for a20
select * from system.DDL_ACTIONS;


-> Incluido no monitoramento:
INSERT INTO IMM$CRITICAL_JOBS_MONITOR VALUES('SYSTEM', 'delete from system.DDL_ACTIONS where ddl_date < sysdate - 60;', 10, 5760, 'Y');

[oracle@sarnia tmp]$ cat ora_critical_jobs_orausdw_02.txt
------------------------------------
CHECKDATE: 2012 05 22 15 43 20
STATUS...: SUCCESS
------------------------------------

Favor validar se isso atende os requisitos, caso contrário posso tentar outra alternativa...


Att, 

Thiago Leite