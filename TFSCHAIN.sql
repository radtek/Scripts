SET ECHO off 
REM NAME:   TFSCHAIN.SQL 
REM USAGE:"@path/tfschain chained_table" 
REM -------------------------------------------------------------------------- 
REM REQUIREMENTS: 
REM    CREATE TABLE, INSERT/SELECT/DELETE on the chained table 
REM    The following script was adapted from a demo script which created a 
REM    table with chained rows, then showed how to eliminate the chaining. 
REM    As modified, this script performs the following actions: 
REM 
REM	1.  Accepts a table name (which has chained rows) 
REM	2.  ANALYZEs the table and store the rows in CHAINED_ROWS 
REM	3.  CREATEs AS SELECT a temporary table with the chained rows 
REM	4.  DELETEs the rows from the original table 
REM	5.  INSERTs the rows from the temp table back into the original 
REM 
REM    This script will NOT work if the rows of the table are actually  
REM    too large to fit in a single block. 
REM -------------------------------------------------------------------------- 
REM Main text of script follows: 
 
set ECHO off  
  
ACCEPT chaintabl PROMPT 'Enter the table with chained rows: '  
  
drop table chaintemp;  
drop table chained_rows; 
  
start $ORACLE_HOME/rdbms/admin/utlchain  
 
set ECHO OFF 
  
REM  **********************************************  
REM  **********************************************  
REM  ANALYZE table to locate chained rows  
  
analyze table &chaintabl   
list chained rows into chained_rows;   
  
REM  **********************************************  
REM  **********************************************  
REM  CREATE Temporary table with the chained rows  
  
create table chaintemp as  
select *  
from &chaintabl  
where rowid in (select head_rowid  
		from chained_rows);  
  
REM  **********************************************  
REM  **********************************************  
REM  DELETE the chained rows from the original table  
  
delete from &chaintabl  
where rowid in (select head_rowid  
		from chained_rows); 
  
REM  **********************************************  
REM  **********************************************  
REM  INSERT the formerly chained rows back into table  
  
insert into &chaintabl  
select *  
from chaintemp; 
  
REM  **********************************************  
REM  **********************************************  
REM  DROP the temporary table  
  
drop table chaintemp;  
 
