#########################################################################################################
#####################################  PRÁTICA ##########################################################
#########################################################################################################


#########################################################################################################
############################## CAPTURA/SELECAO DE PLANO #################################################
#########################################################################################################
	
################################### AUTOMATICA ##########################################################
		1)  CLEAN DO AMBIENTE (CONECTADO COMO SYS):
			alter system flush shared_pool;
		
			truncate table sys.sqllog$;
			
			DECLARE
			   cursor c_s IS SELECT sql_handle FROM dba_sql_plan_baselines;
			  --WHERE parsing_schema_name='schema';
			  nRet NUMBER;
			BEGIN
			  FOR rec IN c_s loop
				BEGIN
				  nRet := dbms_spm.drop_sql_plan_baseline(rec.sql_handle);
				exception
				  -- I know, this is BAD, so, do not use it in your production code
				  WHEN others THEN NULL;
				END;
			   END loop;
			  commit;
			END;
			 /		 
			ALTER system SET OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES=false;
			
			exec DBMS_SQLTUNE.drop_sqlset('MySqlSet', 'SYSTEM');
			
			drop table system.STG_TABLE;

		2) COMO SYSTEM DAQUI PARA FRENTE, VERIFICA LOG:
			@spm_log
			
			@spm_list

		3) ATIVAR CAPTURA AUTOMATICA NA SESSÃO
			--> Simular a captura de planos
			show parameter baselines
			ALTER SESSION SET OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES=true;

		4) CONSULTA:			
			select /* AUTO */ * from hr.employees where salary > 12000;
			
			select /* AUTO */ * from hr.employees where salary > 13000;

		5) VERIFICA LOG:
			@spm_log
			
			@spm_list

		6) REPETE SQL 1:
			select /* AUTO */ * from hr.employees where salary > 12000;
			
		7) BASELINE:
			@spm_log
			
			@spm_list

		8) REPETE SQL 2:
			select /* AUTO */ * from hr.employees where salary > 13000;
		
		9) BASELINE:
			@spm_log
			
			@spm_list
			
		10) VALIDANDO:
			explain plan for
				select /* AUTO */ * from hr.employees where salary > 12000
			
			@showplantable			
				ver "note"
			
			ou 			
				--> pode não encontrar, porque não tem ainda a referencia do sql_plan_baseline, necessário flush da shared pool
				select sql_id, sql_plan_baseline from v$sql where exact_matching_signature = 2641665570254876924 and upper(sql_text) not like '%EXPLAIN%';
				@spm_showplan_sqlid
					9g1j9vgy84a7v
		
		11) Desativar coleta automatica
			ALTER SESSION SET OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES=false;

##################################### MANUAL ############################################################					
			
*************** SQL TUNING SET **************************************************************************				
				******* REFERENCIAS
					LOAD_PLANS_FROM_SQLSET -> AWR					
						-> sqlset_name = nome do SQL Tuning Set
						-> basic_filter = Filtro a ser aplicado, WHERE no sql_tuning_set
						-> fixed = default no, ou seja, carregado como nonfixed
				0) Desativar coleta automatica
					ALTER SESSION SET OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES=false;
					
				1) CRIAR SQL TUNING SET (STS)
					Exec DBMS_SQLTUNE.create_sqlset (sqlset_name => 'MySqlSet', description => 'SQL Tuning set demonstration');
									
				2) GERAR SQL NO AWR					
					SELECT /* STS */ *
					FROM (
						SELECT tbl.*
							,rownum rn
						FROM (
							SELECT d.department_name
								,e.last_name
								,e.first_name
								,e.hire_date
								,e.salary
							FROM hr.departments d
							INNER JOIN hr.employees e 
							ON d.department_id = e.department_id
							WHERE salary > 0
							ORDER BY e.salary DESC
								,e.hire_date
							) tbl
						WHERE rownum <= 2 * 10
						)
					WHERE rn > (2 - 1) * 10;
				
					@findsqltext 
						STS%hr.departments
						6tyu7mbc68pq4
						
					@awr_addsql
										
					@awr_snap
				
				3) CARREGAR PLANOS DO AWR NO STS (PODERIA SER DO CACHE)
					-- select min(snap_id), max(snap_id) from dba_hist_snapshot;
					-- 291          333
					declare
						baseline_ref_cursor DBMS_SQLTUNE.SQLSET_CURSOR;
					begin
						open baseline_ref_cursor for
						select VALUE(p) from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(291, 341,'sql_id='||CHR(39)||'6tyu7mbc68pq4'||CHR(39),NULL,NULL,NULL,NULL,NULL,NULL,'ALL')) p;
						
						DBMS_SQLTUNE.LOAD_SQLSET('MySqlSet', baseline_ref_cursor);
					end;
					/
				
				4) LISTAR INFORMAÇÕES DO STS
					SELECT sqlset_owner, SQL_ID, substr(sql_text,1, 50) text FROM   DBA_SQLSET_STATEMENTS WHERE  SQLSET_NAME = 'MySqlSet' ORDER BY SQL_ID;
					
					SELECT * FROM table (DBMS_XPLAN.DISPLAY_SQLSET('MySqlSet','6tyu7mbc68pq4'));
					
				5) LISTAR BASELINES DISPONIVEIS ANTES DE CARREGAR
					@spm_list
				
				6) CARREGAR SQL PLAN BASELINE 
					set serveroutput on
					declare
						my_integer pls_integer;
					begin
						my_integer := dbms_spm.load_plans_from_sqlset(sqlset_name => 'MySqlSet',
															  sqlset_owner => 'SYSTEM',
															  fixed => 'NO',
															  enabled => 'YES');
						DBMS_OUTPUT.PUT_line('Carregados: ' || to_char(my_integer));
					end;
					/
					
				7) LISTAR BASELINES DISPONIVEIS 
					@spm_list
				
				8) VALIDAR SE SESSÃO USANDO 
					explain plan for
					SELECT /* STS */ *
					FROM (
						SELECT tbl.*
							,rownum rn
						FROM (
							SELECT d.department_name
								,e.last_name
								,e.first_name
								,e.hire_date
								,e.salary
							FROM hr.departments d
							INNER JOIN hr.employees e 
							ON d.department_id = e.department_id
							WHERE salary > 0
							ORDER BY e.salary DESC
								,e.hire_date
							) tbl
						WHERE rownum <= 2 * 10
						)
					WHERE rn > (2 - 1) * 10;
					
					@showplantable									
						ver "note"
									
					@spm_list
					@spm_showplan
						SQL_PLAN_aw4rd2y7wbwmb6190933b
				
********************** CACHE **************************************************************************							
			1) EXECUTAR A CONSULTA			
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
					
			2) ENCONTRAR NO CACHE
				@findsqltext
					CACHE
					2p0bntnjt2509
			
			3) LISTA SQL PLAN BASELINE ANTES
				@spm_list
			
			4) CARREGAR BASELINE:
				VARIABLE cnt NUMBER
				EXECUTE :cnt := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id => '2p0bntnjt2509');
				print :cnt

			5) LISTA SQL PLAN BASELINE DEPOIS
				@spm_list
				
			6) VALIDAR
				explain plan for
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
				
				@showplantable			
				ver "note"
			
				ou 			
				
				select sql_id, sql_plan_baseline from v$sql where exact_matching_signature = 7197537839947359815 and upper(sql_text) not like '%EXPLAIN%';
				
				--> Executar a consulta novamente para preencher a v$sql com o baseline
				@spm_list --> deve listar o sql_id
				
				@spm_showplan_sqlid
					2p0bntnjt2509

********************** STAGE TABLE *********************************************************************												
				--> ORIGEM:
					1) CRIAR TABELA NA ORIGEM 
						exec DBMS_SPM.CREATE_STGTAB_BASELINE (table_name => 'STG_TABLE');
						desc STG_TABLE
					2) EXPORTA PARA A TABELA DE ESTAGIO OS SQL PLAN BASELINE (DIVERSOS FILTROS):
						VARIABLE cnt NUMBER
						EXECUTE :cnt := DBMS_SPM.PACK_STGTAB_BASELINE (table_name => 'STG_TABLE', enabled => 'yes',  creator => 'SYSTEM' );
						print :cnt
					
						select * from STG_TABLE;
						
					3) EXPORTAR TABELA VIA DATAPUMP
						expdp system/oracle dumpfile=spm.dmp logfile=spm.log tables=SYSTEM.STG_TABLE directory=TMP REUSE_DUMPFILES=y
					
					4) MOVER PARA O DESTINO
						-> no exemplo vamos remover o conteudo da base de dados atual
						@spm_drop_baseline_all
							SYSTEM
						DROP TABLE SYSTEM.STG_TABLE;
						
				--> DESTINO
					1) IMPORTAR DUMP
						impdp system/oracle dumpfile=spm.dmp logfile=spm.log directory=TMP
						
						select * from SYSTEM.STG_TABLE;
						
					2) IMPORTA PARA DA TABELA DE ESTAGIO OS SQL PLAN BASELINE (DIVERSOS FILTROS):					
						--> Nada a importar
							VARIABLE cnt NUMBER
							EXECUTE :cnt := DBMS_SPM.UNPACK_STGTAB_BASELINE (table_name => 'STG_TABLE', fixed  => 'yes');
							print :cnt
						--> Importa tudo
							VARIABLE cnt NUMBER
							EXECUTE :cnt := DBMS_SPM.UNPACK_STGTAB_BASELINE (table_name => 'STG_TABLE');
							print :cnt
					3) VALIDAR
						@spm_list
					
********************** STORED_OUTLINE *****************************************************************												
				1) CRIAR OUTLINE:									
					-- alter session set create_stored_outlines
					
					CREATE OUTLINE outln_teste FOR CATEGORY spm
					ON SELECT last_name, salary FROM hr.employees where MANAGER_ID is null;
					
				2) VALIDAR INFORMAÇÕES DO OUTLINE CRIADO
					col SQL_TEXT for a100 
					col name for a20
					col category for a20
					select name, sql_text, category, used from dba_outlines;
					
					COLUMN hint FORMAT A50
					SELECT node, stage, join_pos, hint FROM dba_outline_hints WHERE name = 'OUTLN_TESTE';
				3) TESTAR OUTLINE
					--> Validar se usado:
						select name, sql_text, category, used from dba_outlines;
					
					--> validar:					
						ALTER SESSION SET query_rewrite_enabled=TRUE;
						ALTER SESSION SET use_stored_outlines=spm;
					
						SELECT last_name, salary FROM hr.employees where MANAGER_ID is null;
					
					--> Validar se usado:
						select name, sql_text, category, used from dba_outlines;
				
				4) MIGRAR OUTLINE PARA SPM
					var report clob
					exec :report:=DBMS_SPM.MIGRATE_STORED_OUTLINE(attribute_name=>'ALL'); 
					print :report
				
				5) DROP DO OUTLINE E DESATIVA NA SESSÃO
					select name, sql_text, category, used from dba_outlines;
					exec DBMS_OUTLN.drop_by_cat (cat => 'SPM');									
					select name, sql_text, category, used from dba_outlines;
					
					ALTER SESSION SET use_stored_outlines=;
					
				6) LISTA SQL PLAN BASELINE
					@spm_list
				
				7) VALIDAR O USO
					Explain plan for
						SELECT last_name, salary FROM hr.employees where MANAGER_ID is null;
						
					@showplantable
				
					ver "note"
			
					ou 								
					alter system flush shared_pool;
					
					SELECT last_name, salary FROM hr.employees where MANAGER_ID is null;
					
					select sql_id, sql_plan_baseline, OUTLINE_CATEGORY from v$sql where exact_matching_signature = 6198906265684544677 and upper(sql_text) not like '%EXPLAIN%';
					@spm_showplan_sqlid
						cacgnjau8v9ka

#########################################################################################################
############################## DESATIVAR O USO NO BANCO DE DADOS ########################################
#########################################################################################################
					
	1) VALIDA PARAMETRO E AJUSTA		
		 show parameter BASELINE;
		 ALTER SYSTEM SET OPTIMIZER_USE_SQL_PLAN_BASELINES=false;
		 
	2) Validar:
		Explain plan for
			SELECT last_name, salary FROM hr.employees where MANAGER_ID is null;
						
		@showplantable
		
	3) ATIVAR NOVAMENTE E VALIDAR
		ALTER SYSTEM SET OPTIMIZER_USE_SQL_PLAN_BASELINES=true;
		
		Explain plan for
			SELECT last_name, salary FROM hr.employees where MANAGER_ID is null;
						
		@showplantable
		
#########################################################################################################
##################################### EVOLUINDO PLANOS ##################################################
#########################################################################################################
													
		1) LIMPAR TODOS OS BASELINES		
			@spm_list
					
			
			@spm_drop_baseline_all
				SYSTEM
			
			@spm_list
	
		2) IMPLANTAR PROBLEMA:
			ANALYZE TABLE HR.departments DELETE STATISTICS;
			DROP INDEX HR.DEPT_LOCATION_IX;
			
			alter system flush shared_pool;
	
		3) CARREGAR A CONSULTA PARA O CACHE DO ORACLE E BUSCAR SQL_ID
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
					
				@findsqltext 
					CACHE%hr.Countries
					2p0bntnjt2509
					
				
		
		4) LISTA SQL PLAN BASELINE ANTES
			@spm_list
			
		5) CARREGAR BASELINE:
			VARIABLE cnt NUMBER
			EXECUTE :cnt := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(sql_id => '2p0bntnjt2509');
			print :cnt
			
			alter system flush shared_pool;

		6) LISTA SQL PLAN BASELINE DEPOIS
			@spm_list
				
			
		7) VALIDAR
				explain plan for
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
				
				@showplantable
				ver "note"
			
				
				--> Executar a consulta novamente para preencher a v$sql com o baseline
				set autotrace on
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
				set autotrace off
				
				
				@spm_list --> deve listar o sql_id
				
				select sql_id, sql_plan_baseline, OUTLINE_CATEGORY from v$sql where exact_matching_signature = 7197537839947359815 and upper(sql_text) not like '%EXPLAIN%';
				
				@spm_showplan_sqlid
					2p0bntnjt2509					
		
		8) ANALIZANDO O PROBLEMA E RESOLVENDO CRIANDO NOVOS INDICES E COLETANDO STATISTISCAS NA TABELA DEPARTMENTS:
			TABLE ACCESS FULL            | DEPARTMENTS
				11 - filter("D"."LOCATION_ID"=2700)
				
			--> Vistualizar na ferramenta de tuning
				
			Criar novo indice e coleta statisticas:
				EXEC DBMS_STATS.GATHER_TABLE_STATS ('HR', 'DEPARTMENTS');
				CREATE INDEX "HR"."DEPT_LOCATION_IX" 
				ON "HR"."DEPARTMENTS" ("LOCATION_ID")
				NOLOGGING
				TABLESPACE "USERS";
							
			alter system flush shared_pool;
			
			Executa a consulta:
				set autotrace on
				SELECT  /* CACHE */
						 COUNTRY_NAME
						,Region_name
						,CITY
						,STATE_PROVINCE
						,STREET_ADDRESS
						,Department_name
						,e.last_name
						,e.first_name
					FROM hr.Countries C
						INNER JOIN hr.regions R 
							ON R.region_id = C.region_id
						INNER JOIN hr.locations L 
							ON L.country_id = C.country_id
						INNER JOIN hr.departments D 
							ON D.location_id = L.location_id
						INNER JOIN hr.EMPLOYEES E 
							ON E.department_id = D.department_id
					WHERE country_name LIKE '%er%'
						AND D.location_id = 2700;
				set autotrace off
				
			@spm_list - AUTO-CAPTURE - SQL_PLAN_67sqahzzrx9k724980d06
				-> Novo plano como não aceito
			@spm_showplan 
				SQL_PLAN_67sqahzzrx9k724980d06
		
		9) VALIDAR CONSULTA SE AINDA PEGA O PLANO ANTERIOR:
			explain plan for
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
				
				@showplantable			
				
			alter session set optimizer_use_sql_plan_baselines=false;
				--> Já pega o plano correto:
				TABLE ACCESS BY INDEX ROWID  | DEPARTMENTS
					INDEX RANGE SCAN         | DEPT_LOCATION_IX		
			
			-- testa novamente com o parametro desativado
			explain plan for
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
				
				@showplantable			
			
			-- reativa o parametro 
				alter session set optimizer_use_sql_plan_baselines=true;
			
		10) EVOLUINDO O PLANO:
			@spm_list
			
			-- apenas visualizando comparação
				--@spm_evolve
					SET SERVEROUTPUT ON
					SET LONG 10000
					 DECLARE
						report clob;
					 BEGIN
						report := DBMS_SPM.EVOLVE_SQL_PLAN_BASELINE(
								sql_handle => 'SQL_63e2ca87ff7ea647', plan_name => NULL, time_limit => DBMS_SPM.AUTO_LIMIT, verify=> 'YES', commit=> 'NO');
						DBMS_OUTPUT.PUT_LINE(report);
					 END;
					 /
							
			
			@spm_list
				
			--> aceitando novo plano:
				--@spm_evolve
					SET SERVEROUTPUT ON
					SET LONG 10000
					 DECLARE
						report clob;
					 BEGIN
						report := DBMS_SPM.EVOLVE_SQL_PLAN_BASELINE(
								sql_handle => 'SQL_63e2ca87ff7ea647', plan_name => NULL, time_limit => DBMS_SPM.AUTO_LIMIT, verify=> 'YES', commit=> 'YES');
						DBMS_OUTPUT.PUT_LINE(report);
					 END;
					 /
			
			@spm_list
			
			
			-- se for o caso podemos alterar:
				ALTER SYSTEM SET "_plan_verify_improvement_margin"=120;
		
		11) VALIDAR O PLANO PLANO ACEITO
		
			--> já deve pegar o plano novo
			explain plan for
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
				
				@showplantable
		
			--> 2 planos ficam como aceitos
				--> Podemos desativar o antigo MANUAL-LOAD
					variable cnt number;
					exec :cnt :=DBMS_SPM.ALTER_SQL_PLAN_BASELINE(SQL_HANDLE => 'SQL_63e2ca87ff7ea647', PLAN_NAME => 'SQL_PLAN_67sqahzzrx9k775b66c7c', ATTRIBUTE_NAME => 'enabled',  ATTRIBUTE_VALUE => 'NO');
					print :cnt						
			@spm_list
				
			set autotrace on
				SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;				
			set autotrace off
		
		12) SE PLANO NÃO MAIS REPRODUZIVEL ENTÃO USA OUTRO PLANO :
			@spm_list
			
			ANALYZE TABLE HR.departments DELETE STATISTICS;
			DROP INDEX HR.DEPT_LOCATION_IX;
			
			set autotrace on
			SELECT  /* CACHE */
					 COUNTRY_NAME
					,Region_name
					,CITY
					,STATE_PROVINCE
					,STREET_ADDRESS
					,Department_name
					,e.last_name
					,e.first_name
				FROM hr.Countries C
					INNER JOIN hr.regions R 
						ON R.region_id = C.region_id
					INNER JOIN hr.locations L 
						ON L.country_id = C.country_id
					INNER JOIN hr.departments D 
						ON D.location_id = L.location_id
					INNER JOIN hr.EMPLOYEES E 
						ON E.department_id = D.department_id
				WHERE country_name LIKE '%er%'
					AND D.location_id = 2700;
			set autotrace off
			
						
			@spm_list
				REPRODUCED = NO e usa o plano default
		

#########################################################################################################
################################# MANUTENCAO SQL MANAGEMENT BASE ########################################
#########################################################################################################
		1) VISUALIZANDO PARAMETROS:
			SELECT parameter_name, parameter_value
			FROM   dba_sql_management_config;
		
		2) ALTERANDO VALORES:
			BEGIN
				DBMS_SPM.configure('space_budget_percent', 11); -- entre 1 e 50 percentual da sysuax que pode ser usado
				DBMS_SPM.configure('plan_retention_weeks', 54); -- entre 5 e 523 weeks que os planos podem ser mantidos
			END;
			/
		3) VISUALIZANDO PARAMETROS:
			SELECT parameter_name, parameter_value
			FROM   dba_sql_management_config;	
			
		4) ROLLBACK
			BEGIN
				DBMS_SPM.configure('space_budget_percent', 10); -- entre 1 e 50 percentual da sysuax que pode ser usado
				DBMS_SPM.configure('plan_retention_weeks', 53); -- entre 5 e 523 weeks que os planos podem ser mantidos
			END;
			/
		5) Visualizando parametros:
			SELECT parameter_name, parameter_value
			FROM   dba_sql_management_config;	
	

#########################################################################################################
################################# TROCANDO PLANO SEM ALTERAR CONSULTA ########################################
#########################################################################################################


		0) CLEAN DO AMBIENTE
			@spm_drop_baseline_all
				SYSTEM
			@spm_list
			
			alter system flush shared_pool;
		
		1) VALIDAR CONSULTAS:
			select /*+ TROCA_PLANO */ * from hr.employees where MANAGER_ID = 100;	
			
			@indexes
				hr
				employees
			
			--> Acesso pelo indice EMP_MANAGER_IX
			explain plan 
			for select /*+ TROCA_PLANO */ * from hr.employees where MANAGER_ID = 100;	
			
			@showplantable
			
			explain plan 
			for select /*+ FULL(employees) NOVO_PLANO */ * from hr.employees where MANAGER_ID = 100;
			
			@showplantable
		
		2) EXECUTAR AMBAS E BUSCAR SQL_ID
			select /*+ TROCA_PLANO */ * from hr.employees where MANAGER_ID = 100;	
			@findsqltext
				TROCA_PLANO
				51dx1udt2q02m
			
			
			select /*+ FULL(employees) NOVO_PLANO */ * from hr.employees where MANAGER_ID = 100;
			@findsqltext
				NOVO_PLANO
				bzpvn1pnxh5a4 - 1445457117
				
		3) GERAR O BASELINE DA CONSULTA ATUAL SEM HINTS
			variable cnt number; 
			EXECUTE :cnt:= DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE( sql_id=>'51dx1udt2q02m'); 
			print :cnt
		
			@spm_list
				-> Anotar 
					sql_handle SQL_a14ccaeee037ca52           
					plan_name  SQL_PLAN_a2m6axvh3gkkk366691ab 
			
			-> validar
			explain plan for
				select /*+ TROCA_PLANO */ * from hr.employees where MANAGER_ID = 100;	
			@showplantable			
									
		4) USAR SQL_ID E PLAN_HASH_VALUE DO NOVO SQL PARA CRIAR UM NOVO BASELINE JÁ ACEITO E ASSOCIADO COM O SQL ORIGINAL PELO SQL_HANDLE
			variable cnt number; 
			exec :cnt:=DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE( sql_id => 'bzpvn1pnxh5a4', plan_hash_value => 1445457117, sql_handle => 'SQL_a14ccaeee037ca52');
			print :cnt
			
			@spm_list
			
		5) DBMS_SPM.ALTER_SQL_PLAN_BASELINE para desativar plano
			variable cnt number; 
			exec :cnt :=DBMS_SPM.ALTER_SQL_PLAN_BASELINE(SQL_HANDLE => 'SQL_a14ccaeee037ca52', PLAN_NAME => 'SQL_PLAN_a2m6axvh3gkkk366691ab', ATTRIBUTE_NAME => 'enabled',  ATTRIBUTE_VALUE => 'NO');
			print :cnt			
			
			--> validar se enabled=no
			@spm_list
			
			@spm_showplan
				
		
		6) VALIDAR SQL ANTIGO SEM HINT, AGORA DEVE FICAR COM O NOVO PLANO
			explain plan for
				select /*+ TROCA_PLANO */ * from hr.employees where MANAGER_ID = 100;	
			@showplantable											
				
			set autotrace trace
			select /*+ TROCA_PLANO */ * from hr.employees where MANAGER_ID = 100;	
			set autotrace off
				

#########################################################################################################
########################################## TRACE  #######################################################
#########################################################################################################


		1) REMOVER BASELINES
			@spm_list
			
			@spm_drop_baseline_all
				SYSTEM
			
			@spm_list			

			alter system flush shared_pool;
			
		2) CARREGA PLANO:		
			select /*+ TRACE_SESSAO */ * from hr.employees where MANAGER_ID = 100;	
			@findsqltext
				TRACE_SESSAO
				g4c9xbdpa3vj6
		

		3) CARREGAR DO CACHE
			variable cnt number; 
			exec :cnt:=DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE( sql_id => 'g4c9xbdpa3vj6');
			print :cnt
			
			@spm_list
			
		4) VISUALIZAR
			@spm_showplan
				SQL_PLAN_f74gtm5u91tks366691ab
				
			explain plan for
				select /*+ TRACE_SESSAO */ * from hr.employees where MANAGER_ID = 100;	
				
			@showplantable
			
			executa consulta:
				select /*+ TRACE_SESSAO */ * from hr.employees where MANAGER_ID = 100;	
		
		5) ATIVAR TRACE EM UMA NOVA SESSÃO:		
			***Problemas ativar:
				alter session set tracefile_identifier='SPM';
				alter session set events 'trace[RDBMS.SQL_Plan_Management.*]';				
		
		6) EXECUTAR CONSULTA:
				select /*+ TRACE_SESSAO */ * from hr.employees where MANAGER_ID = 100;	
			
		7) DROPAR INDICE
			DROP INDEX "HR"."EMP_MANAGER_IX";
		
		8) EXECUTAR CONSULTA 						
			select /*+ TRACE_SESSAO */ * from hr.employees where MANAGER_ID = 100;			
			
						
		9) ANALISAR TRACE NO SERVER
			cd /u01/app/oracle/diag/rdbms/oratcc/oratcc/trace
			ls -ltrh | grep SPM
			
			Comportamento:
				--> Antes conseguiu reproduzir
				--> remove o indice, comando não suportado pelo SPM
				--> Adicionar o novo plano gerado ao baseline
				--> não consegue reproduzir o plano atual
				--> tenta reproduzir o plano não aceito e adicionado e usa este
				--> marca plano anterior como não reproduzivel
			
			@spm_list
			
		10) ROLLBACK DO INDICE
			CREATE INDEX "HR"."EMP_MANAGER_IX" 
			ON "HR"."EMPLOYEES" ("MANAGER_ID")
			NOLOGGING			
			TABLESPACE "USERS";
				
			--> executa a consulta, já usa o plano com o indice e marca como reproduzivel novamente:
				set autotrace on
				select /*+ TRACE_SESSAO */ * from hr.employees where MANAGER_ID = 100;	
				set autotrace off
				
			@spm_List
				
		11) CLEAN DO AMBIENTE			
			@spm_drop_baseline_all
				SYSTEM
			
			@spm_list			


####################################################################################################################################################