prompt 
prompt necessário eliminar large a "anonymous blocks" e trocar por uma chamada de uma package
prompt
select sql_text from v$sqlarea
where command_type=47 
and length(sql_text) > 500;
