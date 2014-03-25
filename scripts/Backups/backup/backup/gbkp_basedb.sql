
CONNECT BKP/BKPoradb1

set linesize 200
set serveroutput on;
set feedback off
set termout off

spool /o01/app/oracle/oracledba/backup/bkp_basedb.sql


declare
   --
   cursor tbl is
      select tablespace_name
        from dba_tablespaces
       where contents <> 'TEMPORARY';
   --
   cursor dfile (nome_tbl in varchar2) is
      select file_name
        from dba_data_files
       where tablespace_name = nome_tbl;
   --
   v_dir_destino varchar2(200) := '/o03/oradata/oradb1/bkp/';
   --
begin
   --
   -- inicio do backup
   --
   dbms_output.enable (100000);
   dbms_output.put_line('spool /o01/app/oracle/oracledba/logs/bkp_basedb.log');
   dbms_output.put_line('connect bkp/bkporadb1');
   dbms_output.put_line('-----------------------');
   dbms_output.put_line('alter system archive log current;');
   dbms_output.put_line('select * from v$log;');
   dbms_output.put_line('select * from v$thread;');
   dbms_output.put_line('host echo Inicio do Backup Online. >> /o01/app/oracle/oracledba/logs/backup.datas');
   dbms_output.put_line('host date >> /o01/app/oracle/oracledba/logs/backup.datas');
   dbms_output.put_line('-----------------------');

   --
   -- Copia dos datafiles
   --
   for T in tbl
   loop
     --
     dbms_output.put_line('-----------------------');
     dbms_output.put_line('Prompt Inicio do Backup da tablespace:'||T.tablespace_name||'...');
     dbms_output.put_line ('ALTER TABLESPACE '||T.TABLESPACE_NAME||' BEGIN BACKUP;');
     --
     for F in dfile (T.tablespace_name)
     loop
       --
       -- v_dir_destino := replace(F.file_name,'oradb1','backup');

       dbms_output.put_line ('host cp '||F.file_name||' '||v_dir_destino);
       --
     end loop;
     --
     dbms_output.put_line ('ALTER TABLESPACE '||T.TABLESPACE_NAME||' END BACKUP;');
     --
     --dbms_output.put_line('alter system archive log current;');
     --
     dbms_output.put_line('-----------------------');
     dbms_output.put_line('Prompt Final do Backup da tablespace:'||T.tablespace_name||'...');
   end loop;
   --
   -- Fim do backup
   --
   dbms_output.put_line('-----------------------');
   dbms_output.put_line('alter database backup controlfile to trace;');
   dbms_output.put_line('alter database backup controlfile to '||'''/o03/oradata/oradb1/bkp/backup_control.basedb'||''' reuse;');
   dbms_output.put_line('-----------------------');
   dbms_output.put_line('alter system archive log current;');
   dbms_output.put_line('select * from v$log;');
   dbms_output.put_line('select * from v$thread;');
   dbms_output.put_line('-----------------------');
   dbms_output.put_line('host echo Final do Backup Online >> /o01/app/oracle/oracledba/logs/backup.datas');
   dbms_output.put_line('host date >> /o01/app/oracle/oracledba/logs/backup.datas');
   dbms_output.put_line('-----------------------');
   dbms_output.put_line('spool off;');
   dbms_output.put_line('exit;');
   --
end;
/

spool off;

exit;

