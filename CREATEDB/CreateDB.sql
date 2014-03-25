define dir_scripts=&1
define dir_data=&2
define oracle_sid=&3

connect SYS/change_on_install as SYSDBA
set echo on
spool &dir_scripts/CreateDB.log
shutdown abort;
startup nomount;
CREATE DATABASE &oracle_sid
MAXINSTANCES 9
MAXLOGHISTORY 8822
MAXLOGFILES 72
MAXLOGMEMBERS 3
MAXDATAFILES 1024
DATAFILE '&dir_data/system01.dbf' SIZE 300M REUSE AUTOEXTEND ON NEXT 100m MAXSIZE 2000m EXTENT MANAGEMENT LOCAL
DEFAULT TEMPORARY TABLESPACE TEMPORARY TEMPFILE '&dir_data/temporary01.dbf' SIZE 800M AUTOEXTEND ON NEXT  100m MAXSIZE 2000m
UNDO TABLESPACE "UNDOTBS01" DATAFILE '&dir_data/undotbs01_01.dbf' SIZE 1200M  AUTOEXTEND ON NEXT  100m MAXSIZE 2000m
SYSAUX DATAFILE '&dir_data/sysaux01.dbf' size 100m autoextend on next 100m maxsize 2000m
CHARACTER SET AL32UTF8
NATIONAL CHARACTER SET AL16UTF16
LOGFILE
GROUP 1 ('&dir_data/redo01.log') SIZE 64M,
GROUP 2 ('&dir_data/redo02.log') SIZE 64M,
GROUP 3 ('&dir_data/redo03.log') SIZE 64M;
spool off
exit;
