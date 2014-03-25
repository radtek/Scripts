

---------- Gerar report --------------
	connect perfstat/perfstat
        @?/rdbms/admin/spreport ou  
	@?/rdbms/admin/sprsqins  
	-- solicita snap inicial e final e outputfile

------ coletando um snap -----------
       connect perfstat/perfstat
       execute statspack.snap;

	mais detalhamento:
	execute statspack.snap(i_snap_level=>6); 

	somente 1 sessão:
	execute statspack.snap(i_session_id=>3); 

	


----- instalar -----------
	- ideal tablespace não system, sugestão tools
	connect / as sysdba
	define default_tablespace='tools'
        define temporary_tablespace='temp'
        @?/rdbms/admin/spcreate


------- remover ----------
	connect / as sysdba
        @?/rdbms/admin/spdrop


---------- purge --------
SQL> variable num_snaps number; 
SQL> begin 
SQL> :num_snaps := statspack.purge 
( i_begin_snap=>1237, i_end_snap=>1241 
, i_extended_purge=>TRUE); 
SQL> end; 
SQL> / 
SQL> print num_snaps 

ou

SQL> exec statspack.purge - 
(i_begin_date=>to_date('01-JAN-2003', 'DD-MON-YYYY'), - 
i_end_date =>to_date('02-JAN-2003', 'DD-MON-YYYY'), - 
i_extended_purge=>TRUE); 

-- older than
SQL> exec statspack.purge(to_date('31-OCT-2002','DD-MON-YYYY')); 


--- snapid
exec statspack.purge(31); 

obs: use make_baseline para evitar de snap ser excluido no purge