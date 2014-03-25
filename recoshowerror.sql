store set plus replace 
col name format a30
col tablespace_name format a30

set pages 1000
prompt v$datafile_header 
select file#, status, error, recover, tablespace_name, name 
from v$datafile_header 
where recover = 'YES' 
	or (recover is null and error is not null); 

prompt v$recover_file
COL df# FORMAT 999
COL df_name FORMAT a20
COL tbsp_name FORMAT a10
COL status FORMAT a7
COL error FORMAT a10

SELECT r.file# AS df#, d.name AS df_name, t.name AS tbsp_name, 
       d.status, r.error, r.change#, r.time
FROM v$recover_file r, v$datafile d, v$tablespace t
WHERE t.ts# = d.ts#
AND d.file# = r.file#

prompt arquivos para recovery
select archive_name from v$recovery_log;

@plus



