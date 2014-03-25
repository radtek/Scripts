set heading off
   set echo off
   set feedback off
   set pages 10000
   spool stopmonitor.sql
   select 'alter index '||owner||'.'||index_name||' nomonitoring usage;'
   from dba_indexes
   where owner not in ('SYS','SYSTEM');
   spool off

