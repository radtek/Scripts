--master site
alter session set nls_date_format = 'DD-MON-YY HH24:MI:SS'; 

column Owner format a14 
column Tablename format a14 
column Logname format a10 
column Youngest format a10 
column "Last Refreshed" format a10 
column "Last Refreshed" heading "Last|Refreshed" 
column "MView ID" format 99999 
column "MView ID" heading "Mview|ID" 
column Oldest_ROWID format a10 
column Oldest_PK format a10 

select m.mowner Owner, 
m.master Tablename, 
m.log Logname, 
m.youngest Youngest, 
s.snapid "MView ID", 
s.snaptime "Last Refreshed", 
oldest_pk Oldest_PK 
from sys.mlog$ m, sys.slog$ s 
WHERE s.mowner (+) = m.mowner 
and s.master (+) = m.master; 


--master site
--- rowid
select m.mowner Owner, 
m.master Tablename, 
m.log Logname, 
m.youngest Youngest, 
s.snapid "MView ID", 
s.snaptime "Last Refreshed", 
oldest Oldest_ROWID 
from sys.mlog$ m, sys.slog$ s 
WHERE s.mowner (+) = m.mowner 
and s.master (+) = m.master; 




--- mview site
alter session set nls_date_format = 'DD-MON-YY HH24:MI:SS'; 

column Owner format a14 
column master_owner format a14 

select distinct owner, 
name mview, 
master_owner master_owner, 
last_refresh 
from dba_mview_refresh_times; 

set long 4000 
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS'; 

select query, rewrite_enabled, refresh_mode , refresh_method , 
last_refresh_date, last_refresh_type, staleness, compile_state, 
build_mode , fast_refreshable 
from dba_mviews where mview_name = '<MVIEW_NAME>'; 


-- determinar se é fast_refresh
exec DBMS_MVIEW.EXPLAIN_MVIEW ('owner.materialized_view');

---- Default 10G atomic_refresh=>true, ou seja, todo o processo é feito de modo transacional e os dados estão disponiveis para 
-- o usuário, se false então dados somem devido ao TRUNCATE
-- To force the refresh to do a truncate instead of a delete parameter atomic_refresh must be set to false:
exec dbms_mview.refresh('<mview_name>','C',atomic_refresh=>FALSE)


