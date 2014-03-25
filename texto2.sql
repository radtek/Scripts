set verify off
set feedback off
set long 100000
set longchunksize 100000
var saida clob
accept hash_value prompt 'sql hash_value:'
begin
dbms_lob.createtemporary(:saida, TRUE); for linha in (select sql_text from V$SQLTEXT_WITH_NEWLINES
where hash_value = &hash_value
order by piece)
loop
:saida := :saida ||linha.sql_text;
end loop;
end;
/
select :saida SQL from dual;
set verify on
set feedback on