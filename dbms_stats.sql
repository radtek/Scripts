
-> 11g sugestão é ativar a coleta automatica
	-> job chama DBMS_STATS.GATHER_DATABASE_STATS_JOB_PROC que é o mesmo que executar DBMS_STATS.GATHER_DATABASE_STATS com "GATHER_AUTO" a diferença é que 
	este prioriza objetos que precisam ser atualizados antes que janela de manutenção feche
	-> coleta automatica executa via autotask no oracle scheduler jobs:
		- default é já estar ativado:
			BEGIN
			  DBMS_AUTO_TASK_ADMIN.ENABLE(
				client_name => 'auto optimizer stats collection', 
				operation => NULL, 
				window_name => NULL);
			END;
		- para desativar:
			BEGIN
			  DBMS_AUTO_TASK_ADMIN.DISABLE(
				client_name => 'auto optimizer stats collection', 
				operation => NULL, 
				window_name => NULL);
			END;
		-------11g:
			CHECAR JANELAS DE MANUTENÇÃO
				select window_name,duration from dba_scheduler_windows;

			TASK RUNNING:
				SELECT client_name, window_name, jobs_created, jobs_started, jobs_completed FROM dba_autotask_client_history WHERE client_name like '%stats%';

			CHECK ENABLED
				select client_name,status from Dba_Autotask_Client; 
				select operation_name, status from dba_autotask_operation where client_name like '%stats%';

			ENABLED:
				exec DBMS_AUTO_TASK_ADMIN.ENABLE(
					 client_name => 'auto optimizer stats collection', 
					 operation => NULL, 
					 window_name => NULL);

			EXECUTE MANUAL
				exec DBMS_AUTO_TASK_IMMEDIATE.GATHER_OPTIMIZER_STATS;
		-- 10g
			Apenas habilitar ou desativar o job na dba_Scheduler_jobs
			
	-> esta feature de coleta confia na configuração statistics_level=typical que é o monitoramento basico e default
		- trilha alterações DML desde ultima coleta nas tabelas USER_TAB_MODIFICATIONS 
		- existe um delay para o flush de memoria para catalogo via DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO
		- GATHER_STALE o GATHER_AUTO coleta quando mais de 10% alterado

Analyze
			- só usar para VALIDATE ou LIST CHAINED ROWS
			- coletar informações sobre freelist
		
- coleta manual:
			- depois de uma coleta os cursores dependentes são invalidados e consulta remotas são devem exergar a nova coleta depois de um novo parse
			- objetos volateis, alterado, truncados durante o dia
				1) statisticas podem ser configuradas para null
					- assim quando oracle ver que as estatisticas são null ele vai coletar dinamico via "OPTIMIZER_DYNAMIC_SAMPLING", este nivel deve ser 2 (default) ou mais
					- configurando para null
						BEGIN
						  DBMS_STATS.DELETE_TABLE_STATS('OE','ORDERS');
						  DBMS_STATS.LOCK_TABLE_STATS('OE','ORDERS');
						END;		
					- OPTIMIZER_DYNAMIC_SAMPLING
						0 - não usa dynamic sampling
						1 - usa para todas tabelas não analisadas, se blocos maior que 32 k e não tenha indices
						2 - se pelo menos uma tabela no comando não tem statisticas (coleta 64 blocks)
						3 - se tem expressões ex: WHERE SUBSTR(CUSTLASTNAME,1,3). (coleta 64 blocks)
						4 - se usa predicados complexos(OR AND na mesma tabela) (coleta 64 blocks)
						5 - mesmo que 4 porém coleta 128 blocks
						6 - mesmo que 4 porém coleta 256 blocks
						7 - mesmo que 4 porém coleta 512 blocks
						8 - mesmo que 4 porém coleta 1024 blocks
						9 - mesmo que 4 porém coleta 4086 blocks
						10 - mesmo que 4 porém coleta all blocks
						-> ideal usar para casos onde otimizador devido a predicados complexos ou compostos são está estimando corretamente a selectividade
							-> podemos configurar na sessão, assim usa a coleta dinamica para somar na escolha
							ALTER SESSION SET OPTIMIZER_DYNAMIC_SAMPLING=4;

				2) definir valores de statisticas tipicos e depois bloquear 
					- deve ser mais efetivo
					
			- objetos que são alvos de bulkload, e alteram mais de 10% de dados no dia
				1) coletar imediatamente depois da carga
					GATHER_TABLE_STATS
		
			- external tables 
				ESTIMATE_PERCENT = NULL, 100, or AUTO_SAMPLE, pois sample não é suportado e estas nunca são marcadas como stale
				- se tabela teve alteração então drop stats e coleta novamente
			
			- Fixed tables e view de performance
				- Devemos coletar com GATHER_FIXED_OBJECTS_STATS quando tiver uma quantidade de utilização representativa
			
			- coleta statisticas para tabelas do sys, system e outros schemas opcionais como CTXSYS, DRSYS etc...
				DBMS_STATS.GATHER_DICTIONARY_STATS
			
-> paralllel 
				- DEGREE é possivel informar o parallel 
				- oracle recomenda DBMS_STATS.AUTO_DEGREE, assim ele mesmo determina conforme o tamanho da tabela
				- objetos que não suportam:
					- cluster, domain index, bitmap index
					
-> granalaridade
						- GRANULARITY - informar auto para deixa o oracle escolher de acordo com a tabela
						- se especificar ALL coleta todos os tipos

-> colunas e histogramas
						- default coletar o minimo, min, max, distintos, total
						- oracle recomenda 
							- METHOD_OPT to FOR ALL COLUMNS SIZE AUTO
							- oracle determina quando é necessário o histograma e o numero de buckets 
						- necessário coletar histogramas se dados são desbalanceados
							- informar em METHOD_OPT
							- tipos, para ver DBA_TAB_COL_STATISTICS.HISTOGRAM 
								1) altamente balanceados HEIGHT BALANCED
									- dados distribuidos em buckets do mesmo tamanho
									- bucket 0 tem o menor valor
									- possivel ver na view USER_TAB_HISTOGRAMS
										SELECT ENDPOINT_NUMBER, ENDPOINT_VALUE 
										FROM   USER_TAB_HISTOGRAMS
										WHERE  TABLE_NAME = 'INVENTORIES' AND COLUMN_NAME = 'QUANTITY_ON_HAND'
										ORDER BY ENDPOINT_NUMBER;
									- Exemplo:
										BEGIN
										  DBMS_STATS.GATHER_table_STATS ( 
											OWNNAME    => 'OE', 
											TABNAME    => 'INVENTORIES', 
											METHOD_OPT => 'FOR COLUMNS SIZE 10 quantity_on_hand' );
										END;										
								2) frequencia FREQUENCY
									- Cada valor consiste em  1 bucket
									- database automaticamente criar histograma do tipo FREQUENCY quando a quantidade de valores distinto é menor que a quantidade de buckets
									- USER_TAB_HISTOGRAMS para visualizar
								3) nada NONE
								
-> statisticas extendidas
	1) multicolumn
		- combinação de mutiplas colunas da mesma tabela, seletividade é definida pelo grupo
		- exemplo:
			-> retorna 3 mil registros
				WHERE  cust_state_province = 'CA' 
				AND    country_id=52790;
			-> retorna 0
				WHERE  cust_state_province = 'CA' 
				AND    country_id=52775;
			-> otimizador não tem como saber a seletividade de ambas colunas juntas
		- necessário criar um column group e coletar 
			-> criar column group:
				DECLARE
				  cg_name varchar2(30);
				BEGIN
				  cg_name := dbms_stats.create_extended_stats(null,'customers',  
							 '(cust_state_province,country_id)');
				END;
			-> retornando o nome do column group:
				select sys.dbms_stats.show_extended_stats_name('sh','customers',
					   '(cust_state_province,country_id)') col_group_name 
				from dual;
			-> drop column group
				exec dbms_stats.drop_extended_stats('sh','customers','(cust_state_province,country_id)');
			-> monitorar:
				-> ver groupos:
					Select extension_name, extension 
					from user_stat_extensions 
					where table_name='CUSTOMERS';
				-> ver distintos e tipo de histograma
					select e.extension col_group, t.num_distinct, t.histogram
					from user_stat_extensions e, user_tab_col_statistics t
					where e.extension_name=t.column_name
					and e.table_name=t.table_name
					and t.table_name='CUSTOMERS';
			-> Coletar METHOD_OPT para coletar e criar 
				- FOR ALL COLUMNS SIZE AUTO, coleta automaticamente
				- criar column group e já coleta:
					EXEC DBMS_STATS.GATHER_TABLE_STATS('SH','CUSTOMERS',METHOD_OPT =>'FOR ALL COLUMNS SIZE SKEWONLY FOR COLUMNS (CUST_STATE_PROVINCE,COUNTRY_ID) SIZE SKEWONLY');
	2) expression
		- ter seletividade mais apurada para função 
		  ex: LOWER(CUST_STATE_PROVINCE)='CA';	
		- para criar pode ser UM destes:
			1) exec dbms_stats.gather_table_stats('sh','customers', method_opt =>'for all columns size skewonly for columns (lower(cust_state_province)) size skewonly');		
			2) select dbms_stats.create_extended_stats(null,'customers','(lower(cust_state_province))') from dual;
		- para monitorar:
			-> ver expressoes 
			Select extension_name, extension 
			from user_stat_extensions 
			where table_name='CUSTOMERS';
			-> ver distintos:
				select e.extension col_group, t.num_distinct, t.histogram
			    from user_stat_extensions e, user_tab_col_statistics t
			    where e.extension_name=t.column_name
			    and t.table_name='CUSTOMERS';
		-> dropar 
			exec dbms_stats.drop_extended_stats(null,'customers','(lower(country_id))');


-> determinar se STALE
			- STATISTICS_LEVEL = typical
			- mantém quantidade de alterações USER_TAB_MODIFICATIONS 
			- flush antes de coleta para determinar se stale
				DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO
			- coletar somente STALE quando 10% de alterações:
				OPTIONS=GATHER STALE or GATHER AUTO
	
-> user defined statisticas
	- criando quando cria um indice funcional
	- depois de criar um novo indice funcional é necessário coletar com "METHOD_OPT argument set to FOR ALL HIDDEN COLUMNS"
			
						
-> incremental coleta
						- existem statisticas locais e globais para tabelas particionadas
						- especifica se quando adicionar uma nova partição e carregar os dados se coleta as estatisticas globais fazendo um fullscan ou 
						se somente faz de modo incremental adicionado as statisticas das partições alteradas
						- especifica se faz um fulltable para manter as statisticas globais, o que pode ser muito lento para tabelas grandes
						- INCREMENTAL = true, default false configura para tabela via DBMS_STATS.SET_TABLE_PREF
						- requisitos para evitar o fullscan e a lentidão realizando um incremental coleta
							- tabela particionada
							- INCREMENTAL = true
							- PUBLISH value = true
							- na coleta ESTIMATE_PERCENT=AUTO_SAMPLE_SIZE
							- na coleta GRANULARITY=AUTO
						- coleta incremental tem as seguintes consequencias
							- sysaux ocupa2 mais espa2ço para manter global statisticas para tabelas
							- somente coleta para partições alteradas, sub partitions não alteradas não são coletadas

-> missing statistics
	- quando não existe o otimizador considera
		- tabela:
			- 2000 rows
			- 100 bytes row length
		- indice
			- leaf blocks = 25
			- distinct 100
			- cluster = 800
			- levels = 1

 							
-> nova features 11g, publicar ou colocar como peding uma statisticas
	- default true publicar automaticamente no final da coleta, porém podemos colocar como pendente
		SELECT DBMS_STATS.GET_PREFS('PUBLISH') PUBLISH FROM DUAL;
	- pendentes ficam em:
		-> USER_TAB_PENDING_STATS 
		-> USER_IND_PENDING_STATS
	- exportar para ambiente de teste
		-> DBMS_STATS.EXPORT_PENDING_STATS(…)
	- para testar as pendentes
		alter session set optimizer_use_pending_statistics = TRUE;
	- para publicar as pendentes:
		- Tudo:
			Exec dbms_stats.publish_pending_stats(null, null);
		- tabela:
			Exec dbms_stats.publish_pending_stats('SH','CUSTOMERS');
	- possivel exportar para outro ambiente para teste:
		dbms_stats.export_pending_stats
-> restore de statisticas
				- estatisticas são sempre salvas para futuros restores, estas podem ser restaurads por timestamp
				- statisticas coletadas nivel schema e database 
					prompt historico de coletas:
						select operation, target, start_time, end_time, end_time - start_time total_time 
						from DBA_OPTSTAT_OPERATIONS
						order by start_time;
					prompt coletas por tabela 
						select owner, table_name, paRTITION_NAME, STATS_UPDATE_TIME 
						from DBA_TAB_STATS_HISTORY 
						where owner like upper('&owner') 
						  and table_name like upper('&table_name')
						order by STATS_UPDATE_TIME;
						
						28/09/13 21:49:27,492728 +00:00
						
						
				  - historico de retenção default é 31 dias
						-> purge manual
							DBMS_STATS.PURGE_STATS
						-> visualizar retenção atual
							prompt  Configurar a retenção
							select dbms_stats.GET_STATS_HISTORY_RETENTION() from dual;
							select dbms_stats.GET_STATS_HISTORY_AVAILABILITY() from dual;
							prompt  antiga nunca é salva "exec DBMS_STATS.ALTER_STATS_HISTORY_RETENTION(0);"
							prompt  nunca ocorre o purge "exec DBMS_STATS.ALTER_STATS_HISTORY_RETENTION(1);"
							prompt  default value 31 dias "exec DBMS_STATS.ALTER_STATS_HISTORY_RETENTION(NULL);"
				-> restore table_Stats
					-> quando é feito o drop da tabela o history é perdido
					-> não é possivel fazer restore user defined stats
					exec DBMS_STATS.RESTORE_TABLE_STATS(ownname=>'SYSTEM', tabname=>'A', as_of_timestamp=>to_date('22/01/13 12:05:37', 'DD/MM/RR HH24:MI:SS'), force=>true, no_invalidate=>DBMS_STATS.AUTO_INVALIDATE);
					select num_rows, blocks, to_char(last_analyzed, 'DD-MON-YYYY HH24:MI:SS') from user_tables where table_name ='A';
				
-> para text indexes ela não é compa2tivel portanto devemos usar:	
	ANALYZE TABLE <table_name> COMPUTE STATISTICS; 
	ANALYZE TABLE <table_name> ESTIMATE STATISTICS 50 PERCENT;
	
	DBMS_STATS.GATHER_TABLE_STATSowner', 'table_name',
                                       estimate_percent=>50,
                                       block_sample=>TRUE,
                                       degree=>4) ;
									   
									   
-> preferencias
	-> preferencias:
		- Existem no nivel: 
			- tabela = SET_TABLE_PREFS
			- global = 
		- precedência tabelas -> global
	- se configurar a nivel de schema este afeta a configuraçao das tabelas existens mas não das novas
		- SET_SCHEMA_PREFS
	- se configurar a nivel de database este afeta a configuração corrente não de novas tabelas, esta usam o config global
		- SET_DATABASE_PREFS
	- configurando a nivel global os defaults quando não especificado e para novas tabelas
		SET_GLOBAL_PREFS

-> analisando diferencas em statisticas:
	DIFF_TABLE_STATS_IN_PENDING -> Pending statistics and statistics as of a timestamp or statistics from dictionary
	DIFF_TABLE_STATS_IN_STATTAB -> Statistics for a table from two different sources
	DIFF_TABLE_STATS_IN_HISTORY -> Statistics for a table from two timestamps in pa2st and statistics as of that timestamp

	select * from table(dbms_stats.diff_table_stats_in_history(
						ownname => user,
						tabname => upper('&tabname'),
						time1 => systimestamp,
						time2 => to_timestamp('&time2','yyyy-mm-dd:hh24:mi:ss'),
						pctthreshold => 0));   
						
-> System statistics
	- coleta statisticas de HW para melhor determinar o custo de IO e CPU e assim escolher o melhor plano
	- oracle recomenda coletar
	tipos:
		->>> Workload Statistics
			- Single (sreadtime in ms) and multiblock read times(mreadtim in ms), lookup de indice
			- mbrc = Multiblock count em média que é feito sequenciamente (blocks), necessário executa um fullscan para coletar
				- se não existe usa DB_FILE_MULTIBLOCK_READ_COUNT ou se este for 0 usa 8 para determinar o custo
			- CPU speed (cpuspeed) = ciclos médios por segundo (Millions/sec)
			- Maximum system throughput
			- Average slave throughput
			- coletando em um dos modos:
				1) DBMS_STATS.GATHER_SYSTEM_STATS('start') -> run workload -> DBMS_STATS.GATHER_SYSTEM_STATS('stop')
				2) DBMS_STATS.GATHER_SYSTEM_STATS('interval', interval=>N) = n é total de minutos coletando
			- para excluir 
				dbms_stats.delete_system_stats()
		->>> NonWorkload Statistics
			-> consiste:
				- transfer speed
				- io seek time
				- cpu speed
			-> coletado no startup, oracle usa estes se não tem informações de workload statistics
			-> apesar de ser coletado automaticamente podemos recoletar com 
				DBMS_STATS.GATHER_SYSTEM_STATS() -> sem parametros, coleta e sai fora
			-> valor tipicos:
				ioseektim = 10ms
				iotrfspeed = 4096 bytes/ms
				cpuspeednw = gathered value, varies based on system
			
	
						
-> para deletar
	ANALYZE TABLE <table_name> DELETE STATISTICS;
	ANALYZE INDEX <index_name> DELETE STATISTICS;

---> Collect statistics forn a table with default settings.
	DBMS_STATS.gather_table_stats
	(ownname => USER,
	tabname => 'EMPLOYEES');

-->  Collect statistics for the entire schema.
	DBMS_STATS.gather_schema_stats
	(ownname => 'HR');

--> Collect statistics for any tables in a schema that are “stale.”
	DBMS_STATS.gather_schema_stats
	(ownname => 'HR'
	options => 'GATHER STALE');

--> Create histograms for all indexed columns.
	DBMS_STATS.gather_schema_stats
	(ownname => 'HR',
	method_opt =>'FOR ALL INDEXED COLUMNS SIZE AUTO');

--> Set the default collection to create histograms for indexed columns only if the column has a skewed distribution.
	DBMS_STATS.set_database_prefs(pname => 'METHOD_OPT', pvalue => 'FOR ALL INDEXED COLUMNS SIZE SKEWONLY');

-> Create and export statistics to a statistics table.
	DBMS_STATS.create_stat_table
	(ownname => USER,
	stattab => 'GuysStatTab');

	DBMS_STATS.export_table_stats
	(ownname => USER,
	tabname => 'EMPLOYEES',
	stattab => 'GuysStatTab',
	statid => 'Demo1');
	
--> Import statistics from a statistics table into the current schema.	
	DBMS_STATS.import_table_stats
	(ownname => USER,
	tabname => 'EMPLOYEES',
	stattab => 'GuysStatTab',
	statid => 'Demo1');
	
--> extend statitics para multicolumns e expression
	DBMS_STATS.gather_table_stats
	(ownname => 'SH',
	tabname => 'CUSTOMERS',
	method_opt =>
	'FOR ALL COLUMNS FOR COLUMNS (CUST_GENDER,CUST_FIRST_NAME)'
	);
	
	DBMS_STATS.gather_table_stats
	(ownname => USER,
	tabname => 'SALES',
	method_opt => 'FOR ALL COLUMNS FOR COLUMNS
	(sale_category(amount_sold))'
	);	
	
	DECLARE
		v_extension_name all_stat_extensions.extension_name%TYPE;
	BEGIN
		v_extension_name:=DBMS_STATS.create_extended_stats
		(ownname => 'SH',
		tabname => 'PRODUCTS',
		extension => '(ROUND(prod_list_price,-2))'
		);
	END;
	
--> métodos:
	CREATE_STAT_TABLE -> Create a statistics table that can be used to store statistics for use in EXPORT or IMPORT operations.
	DELETE_{DATABASE| SCHEMA| TABLE|INDEX}_STATS -> Remove statistics for the database, schema, table, or index.
	EXPORT_ {DATABASE| SCHEMA| TABLE| INDEX}_STATS -> Exports statistics from the specified objects, and stores them in a statistics table created CREATE_STAT_TABLE.
	GATHER_COLUMN_STATS -> Gather statistics for a specific column.
	GATHER_DATABASE_STATS -> Gather object statistics for all objects in the database.
	GATHER_DICTIONARY_STATS -> Gather statistics on dictionary tables. These are the tables owned by SYS, SYSTEM and other Oracle internal accounts 
		that contain meta-data relating to segments, tablespa2ces, and so on.	
	GATHER_FIXED_OBJECT_STATS -> Gather statistics on V$ and GV$ fixed tables. These are the dynamic performance tables that expose Oracle performance
		counters, the wait interface, and other performance data.
	GATHER_INDEX_STATS -> Gather statistics for an index.
	GATHER_SCHEMA_STATS -> Gather statistics for all objects in a schema.
	GATHER_TABLE_STATS -> Gather statistics for a single table.
	IMPORT_ {DATABASE| SCHEMA| TABLE|INDEX}_STATS -> Imports statistics from a statistics table created by CREATE_STAT_TABLE.	

--> parametros:
	OWNNAME -> The owner of the object to be analyzed.
	STATTAB -> The name of a statistics table to be used as the source or destination of statistics.
	STATOWN -> Owner of the statistics table.
	STATID -> An identifier to associate with statistics stored in a statistics table.
	NO_INVALIDATE -> If TRUE, don’t invalidate cursors in the shared pool or open in sessions that might depend on the statistics being modified. If
					 NULL or FALSE, any cursor that is dependent on the statistics will be invalidated and will need to be reparsed.
	parTNAME -> Name of a partition to be processed.
	TABNAME -> Name of a table to be processed.
	FORCE -> Gather the statistics, even if the object(s) concerned are locked.
	CASCADE -> If true, cascades the operation to all indexes on the table concerned.
	INDNAME -> Name of an index to be processed.
	ESTIMATE_PERCENT -> The percentage of rows to be sampled for an analysis. Theconstant DBMS_STATS.AUTO_SAMPLE_SIZE enables Oracle to determine the 
					best sample based on the size of the table and possibly other factors.
	DEGREE -> The degree of parallelism to be employed when sampling data. The default value of DBMS_STATS.AUTO_DEGREE results in Oracle choosing the 
			degree based on object storage and instance configuration.
	GRANULARITY -> Controls how partition statistics are collected. Valid values are ALL, AUTO, GLOBAL, parTITION, GLOBAL, AND parTITION, SUBparTITION.
		- global ocorre para toda tabela
		- se incremental = true então somente são coletado as partições que foram alteradas, ideal para time range onde temos apenas 1 ativa
	BLOCK_SAMPLE -> Determines whether to randomly sample blocks rather than rows. It’s faster to sample blocks, but if the data is highly clustered,
					it’s not as accurate.
	METHOD_OPT -> Histogram collection options
				 FOR [ALL {INDEXED|HIDDEN}] COLUMNS [column_expression] [size_clause] [, [column_expression] [size_clause] ]
				 SIZE {bucket_size | REPEAT | AUTO | SKEWONLY}
				 
				 - bucket_size = tamanho do histograma 
				- REPEAT =  somente coleta se já existe
				- AUTO = oracle determina baseado em plano de execução que podem variar por distribuição de dados
				- SKEWONLY = coleta somente se a coluna tem informação com diferentes cardinalidades, mesmo que AUTO, porém não considera planos								
				Dicas:
					-> coletar histogramas para coluna:
						-> FOR COLUMNS SIZE 254 CUST_ID
							dbms_stats.Gather_table_stats('SH', 'SALES', method_opt => 'FOR ALL COLUMNS SIZE 1 FOR COLUMNS SIZE 254 CUST_ID');		
							
							SELECT column_name, num_distinct, histogram  FROM   user_tab_col_statistics  WHERE  table_name = 'SALES'; 
					-> coletar para todas:
						dbms_stats.Gather_table_stats('SH', 'SALES', method_opt => 'FOR COLUMNS SIZE 254 CUST_ID TIME_ID CHANNEL_ID PROMO_ID QUANTITY_SOLD AMOUNT_SOLD'); 
						frequency para quem tem menos de 256 distintos ou high balanced para quem tem mais de 256
					-> criar extend statistics:
						dbms_stats.Gather_table_stats('SH', 'SALES', method_opt => 'FOR ALL COLUMNS SIZE 254 FOR COLUMNS SIZE 254(PROD_ID, CUST_ID)');
						SELECT column_name, num_distinct, histogram FROM   user_tab_col_statistics  WHERE  table_name = 'SALES';
					-> não coletar histogramas:
						-> FOR ALL COLUMNS SIZE 1 
					-> alterar o default method:					
						dbms_stats.Set_table_prefs('SH', 'SALES', 'METHOD_OPT', 'FOR ALL COLUMNS SIZE 254 FOR COLUMNS SIZE 1 PROD_ID');
	OPTIONS -> Controls which objects will have statistics collected. Possible options are
				GATHER (all objects)
				GATHER AUTO (Oracle determines which objects may need statistics)
				GATHER STALE
				GATHER EMPTY
				The last three options have equivalent LIST options that list the objects that would be processed. For instance, LIST STALE
				lists all objects with stale statistics.
				
--> default
	SET_GLOBAL_ PREFS,
	SET_DATABASE_PREFS, 
	SET_SCHEMA_PREFS, 
	SET_TABLE_ PREFS 
	SET_parAMS (10g).
	parametros:
		 CASCADE
		 DEGREE
		 ESTIMATE_PERCENT
		 METHOD_OPT
		 NO_INVALIDATE
		 GRANULARITY
		 PUBLISH
		 INCREMENTAL
		 STALE_PERCENT
	ex:
	BEGIN
		DBMS_STATS.set_schema_prefs (ownname => 'HR',
		pname => 'STALE_PERCENT',
		pvalue => 20
		);
	END;
	
	
--- definir manualmente estatisticas, para homologar o otimizar simulando um crescimento da tabela
BEGIN
	DBMS_STATS.set_table_stats (ownname => USER,
		tabname => 'EMPLOYEES',
		numrows => 10000,
		numblks =>500
		);
		
	DBMS_STATS.set_column_stats (ownname => USER,
		tabname => 'EMPLOYEES',
		colname => 'MANAGER_ID',
		distcnt => 200,
		density => 0.005
		);
END;

---- unock table stats
exec dbms_stats.unlock_table_stats('scott', 'test');
ou usar FORCE=>true na coleta




 NUM_ROWS     BLOCKS
--------- ----------
  4925730     474481



exec DBMS_STATS.set_table_stats (ownname => 'AZTECA', tabname => 'NEWS', numrows => 4925730, numblks => 474481);
exec DBMS_STATS.set_table_stats (ownname => 'AZTECA', tabname => 'NEWS', numrows => 4925730, numblks => 474481);





exec DBMS_STATS.GATHER_TABLE_STATS('PROPHW', 'MTZ_MOVIMENTOS_DE_ESTOQUE_TMP', estimate_percent=>NULL, method_opt =>'FOR ALL COLUMNS SIZE 1', degree=>1, cascade=>true);


-- recoleta deleta histogramas
exec DBMS_STATS.gather_table_stats(ownname => 'SYSTEM', tabname => 'X', method_opt => 'FOR ALL COLUMNS SIZE SKEWONLY');





--> extended statisticas, determinar as necessárias automaticamente:
	1) informar os parametros para monitoramento:
		BEGIN 
			DBMS_STATS.SEED_COL_USAGE(null,null,300); 
		END; 	
	2) Review column usage:
		SELECT DBMS_STATS.REPORT_COL_USAGE(user, ‘customer_test’) FROM dual;
	3) na proxima coleta o oracle cria automaticamente:
		SELECT DBMS_STATS.REPORT_COL_USAGE(user, ‘customer_test’) FROM dual;

		
---------- Sugestão de coleta:
	begin
		dbms_stats.gather_system_stats('START');
		
		sys.dbms_stats.gather_schema_stats('SYS') ;
		dbms_stats.GATHER_FIXED_OBJECTS_STATS;
		DBMS_STATS.GATHER_DICTIONARY_STATS;
		
		DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME => 'MSAF_DFE'
			,ESTIMATE_PERCENT => dbms_stats.auto_sample_size
			,METHOD_OPT => 'FOR ALL COLUMNS SIZE AUTO'
			,DEGREE => 6
			,GRANULARITY => 'ALL'
			,CASCADE => TRUE);
			
		dbms_stats.gather_system_stats('STOP');
	End;
	/		
	
	
	