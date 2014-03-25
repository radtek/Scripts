log do restore do agent
	tail -100f /usr/openv/netbackup/logs/user_ops/dbext/logs/29554.0.1340221018

------------------------------------ RESTORE ------------------------------------
	export NLS_DATE_FORMAT="YYYYMMDDHH24MISS"
	rman target / catalog RMAN/TRR_RMAN_123@oragc trace=$ADM/logs/restore_fp.log <<eof
	SET PARALLELMEDIARESTORE OFF;
	run
	{
	allocate channel c1 type 'sbt_tape';
	allocate channel c2 type 'sbt_tape';
	allocate channel c3 type 'sbt_tape';
	allocate channel c4 type 'sbt_tape';
	allocate channel c5 type 'sbt_tape';
	allocate channel c6 type 'sbt_tape';
	set newname for datafile '/d09/oradata/oraacct2/undotbs01.dbf'  to '/d08/oradata/resfp/undotbs01.dbf';
	set newname for datafile '/d09/oradata/oraacct2/undotbs02.dbf'  to '/d08/oradata/resfp/undotbs02.dbf';
	set newname for datafile '/d09/oradata/oraacct2/undotbs03.dbf'  to '/d08/oradata/resfp/undotbs03.dbf';
	set newname for datafile '/d09/oradata/oraacct2/undotbs04.dbf'  to '/d08/oradata/resfp/undotbs04.dbf';
	set newname for datafile '/d09/oradata/oraacct2/undotbs05.dbf'  to '/d08/oradata/resfp/undotbs05.dbf';

	set newname for datafile '/d09/oradata/oraacct2/system01.dbf'   to '/d08/oradata/resfp/system01.dbf';
	set newname for datafile '/d02/oradata/oraacct2/footprints_2.dbf' to '/d08/oradata/resfp/footprints_2.dbf';
	set newname for datafile '/d03/oradata/oraacct2/FOOTPRINTS.dbf' to '/d08/oradata/resfp/FOOTPRINTS.dbf';
	restore tablespace system,UNDOTBS01,FOOTPRINTS;
	}
	exit;
	eof

	if [ $? = 0 ] ; then
	  echo "Restore finalizado com sucesso."
	else
	  echo "Restore finalizado com erro. Detalhes no log: restore_fp.log"
	fi

------------------------------------------------ BUSCAR ARCHIVES -------------------------------------------~
	/// determinal quais archives precisa aplicar
	select SEQUENCE#, FIRST_TIME from  v$log_history where FIRST_TIME >= '19/06/2012 23:00:00'  order by 1;
 
 
	 export NLS_DATE_FORMAT="dd/mm/yyyy hh24:mi:ss"
	date

	rman target=/ catalog=rman/trr_rman_123@oragc trace=$ADM/logs/restore_archives_2012-06-20.log <<EOF
	run {
	allocate channel c1 type 'sbt_tape';
	allocate channel c2 type 'sbt_tape';
	allocate channel c3 type 'sbt_tape';
	allocate channel c4 type 'sbt_tape';
	restore archivelog from logseq 378010 until logseq 378070;
	}
	exit;
	EOF

	if [ $? = 0 ] ; then
	  echo "Restore finalizado com sucesso."
	else
	  echo "Restore finalizado com erro. Detalhes no log: restore_archives.log"
	fi
	date
~

------------------------ CRIAR INIT E SUBIR A INSTANCE ------------------------------------------

	db_name = "RESFP"
	instance_name = resfp

	service_names = resfp


	control_files = ("/d08/oradata/resfp/control01.ctl")

	#open_cursors = 100 Alterado por Gustavo Silveira dia 06/02/2007 devido a erro em export full
	open_cursors = 200
	#max_enabled_roles = 100
	#db_block_buffers = 200000
	db_cache_size = 100m

	shared_pool_size = 100m

	large_pool_size = 30M
	java_pool_size = 70m

	log_checkpoint_interval = 20000000
	log_checkpoint_timeout = 0

	processes = 200

	log_buffer = 2097152

	# audit_trail = false  # if you want auditing
	 timed_statistics = true  # if you want timed statistics
	 max_dump_file_size = 10000  # limit trace file size to 5M each

	# fica assim mesmo pois vai buscar do local onde estão archives para o recovery
	log_archive_dest  = /archive01/oradata/oraacct2/archive/
	log_archive_format = oraacct2_%s_%t_%r.arc



	# Global Naming -- enforce that a dblink has same name as the db it connects to
	 global_names = false
	# Uncomment the following line if you wish to enable the Oracle Trace product
	# to trace server activity.  This enables scheduling of server collections
	# from the Oracle Enterprise Manager Console.
	# Also, if the oracle_trace_collection_name parameter is non-null,
	# every session will write to the named collection, as well as enabling you
	# to schedule future collections from the console.
	# oracle_trace_enable = true

	# define directories to store trace and alert files
	background_dump_dest = /usr/local/oracle/admin/resfp/bdump
	core_dump_dest = /usr/local/oracle/admin/resfp/cdump
	user_dump_dest = /usr/local/oracle/admin/resfp/udump

	db_block_size = 8192

	remote_login_passwordfile = none

	os_authent_prefix = ""

	# mts_dispatchers = "(PROTOCOL=TCP)(PRE=oracle.aurora.server.SGiopServer)"
	# Uncomment the following line when your listener is configured for SSL
	# (listener.ora and sqlnet.ora)
	# mts_dispatchers = "(PROTOCOL=TCPS)(PRE=oracle.aurora.server.SGiopServer)"

	compatible = "10.2.0"
	sort_area_size = 5000000

	db_file_multiblock_read_count = 128
	#sort_multiblock_read_count    = 64
	#hash_multiblock_io_count      = 32


	query_rewrite_enabled   = true
	query_rewrite_integrity = trusted

	# Jobs
	#job_queue_processes = 9
	job_queue_processes = 0
	#_system_trig_enabled = false



	# DB writer
	#db_block_lru_latches = 4
	db_writer_processes  = 1


	# Interface com F.S
	#utl_file_dir = *

	# Utilizacao de parallel query
	parallel_threads_per_cpu        = 4
	parallel_max_servers            = 16
	parallel_execution_message_size = 8192

	db_files = 2500

	O7_DICTIONARY_ACCESSIBILITY = true
	undo_management = AUTO
	undo_retention = 18000
	undo_tablespace = undotbs01

	_b_tree_bitmap_plans = FALSE

	lock_sga=true


	## Incluidos p/ 10g
	pga_aggregate_target = 2000m
	session_max_open_files = 25
	recyclebin = off

	# Incluido devido a bug 5177766 (Gediel - 12/03/2008)
	session_cached_cursors=0
                                                                          
------------------------------------------------------------------


---------------------- criar um control file para instance ---------
	-> se base pequeno pode fazer um cold backup para evitar de depender da fita se der algum problema

	(4:43:09 PM) gediel.luchetta: tranquilo
	(4:43:14 PM) gediel.luchetta: basta logar na instance 
	(4:43:18 PM) gediel.luchetta: que esta em "nomount"
	(4:43:27 PM) gediel.luchetta: e rodar o script de create controlfile
	(4:43:44 PM) gediel.luchetta: /d08/oradata/resfp/cr_control.sql
	-> rodar script
----------------------------------------------------------------


---------------------- recovery ----------
	Cause ~~~~~~~  The SQL*PLUS command RECOVER DATABASE requires the time argument to be passed  in a fixed format 
	of 'YYYY-MM-DD:HI24:MI:SS' format.  Fix ~~~~  Use the 'YYYY-MM-DD:HI24:MI:SS' format for the timestamp that you specify  in the UNTIL 
	TIME clause.


	SQL> alter session set nls_date_format = 'YYYY-MM-DD:HI24:MI:SS';

	SQL> recover database using backup controlfile until time '2012-06-20:14:40:00';
	ORA-00279: change 6862958273900 generated at 06/20/2012 00:02:00 needed for thread 1
	ORA-00289: suggestion : /archive01/oradata/oraacct2/archive/oraacct2_378011_1_524165804.arc
	ORA-00280: change 6862958273900 for thread 1 is in sequence #378011


	Specify log: {<RET>=suggested | filename | AUTO | CANCEL}

	--> acompanhar pelo alert
		-> max datafiles -> recriar controlfile
		Wed Jun 20 17:21:22 2012
		Errors in file /usr/local/oracle/admin/resfp/udump/resfp_ora_8000.trc:
		ORA-01176: data dictionary has more than the 2048 files allowed by the controlfie
		Error 1176 happened during db open, shutting down database
		USER: terminating instance due to error 1176
		Instance terminated by USER, pid = 8000
		ORA-1092 signalled during: alter database open resetlogs...	
				
			NAME                                 TYPE        VALUE
			------------------------------------ ----------- ------------------------------
			_allow_resetlogs_corruption          boolean     TRUE

		
------------- ------------- adicionar temp file  ------------- ------------- 
	SQL> ALTER TABLESPACE TEMPORARY ADD TEMPFILE '/d08/oradata/resfp/temporary01.dbf' size 100m;
