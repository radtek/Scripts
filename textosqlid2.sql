set verify off
set feedback off
set long 100000
set longchunksize 100000
var saida clob
accept sqlid prompt 'sqlid:'
begin
dbms_lob.createtemporary(:saida, TRUE); for linha in (select sql_text from V$SQLTEXT_WITH_NEWLINES
where sql_id = '&sqlid'
order by piece)
loop
:saida := :saida ||linha.sql_text;
end loop;
end;
/
select :saida SQL from dual;
set verify on
set feedback on
undef sql_id