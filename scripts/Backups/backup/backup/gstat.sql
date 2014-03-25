--
define sortarea= 50000000
define bkpuser = bkp
define bkppass = bkporadb1
define bkpdir  = /u/local/oracle/oracledba/backup
--
conn &bkpuser/&bkppass
set serveroutput on size 1000000;
set feedback off;
set pages 0;
set lines 200;
set ver off;
spool &bkpdir/stat.sql
declare
  --
  cursor c1 is
    select nome_schema
      from system.coleta_stat;
  --
  cursor c2 (p_nome in system.coleta_stat.nome_schema%type) is
    select table_name
      from all_tables
     where owner = p_nome;
  --
  cursor c3 (p_nome in system.coleta_hist.nome_schema%type) is
    select nome_tabela,nome_coluna
      from system.coleta_hist
     where nome_schema = p_nome;
  --
  v_percent number := 50;
  v_log     varchar2(100) := '/u/local/oracle/oracledba/logs/analyze.log';
  v_user    varchar2(30) := '&bkpuser';
  v_senha   varchar2(30) := '&bkppass';
  --
begin
  --
  dbms_output.put_line ('spool '||v_log||';');
  dbms_output.put_line ('conn '||v_user||'/'||v_senha);
  dbms_output.put_line ('set timing on');
  dbms_output.put_line ('set echo on');
  dbms_output.put_line ('alter session set sort_area_size=&sortarea;');
  for c in c1
  loop
    --
    dbms_output.put_line ('select to_char(sysdate,'||''''||'dd/mm/yyyy hh24:mi:ss'||''''||') from dual;');
    dbms_output.put_line ('promp coletando estatÍsticas para o schema:'||c.nome_schema);
    --
    for t in c2 (c.nome_schema)
    loop
      --
      dbms_output.put_line ('prompt tabela '||t.table_name||'...');
      dbms_output.put_line ('analyze table '||c.nome_schema||'.'||t.table_name||
                            ' estimate statistics sample '||v_percent||' percent;');
      --
    end loop;
    --
    for h in c3 (c.nome_schema)
    loop
      --
      dbms_output.put_line ('prompt hist. tabela:'||h.nome_tabela||' coluna:'||h.nome_coluna);
      dbms_output.put_line ('analyze table '||c.nome_schema||'.'||h.nome_tabela||' compute statistics '||
                            'for columns '||h.nome_coluna||';');
      --
    end loop;
    --
    dbms_output.put_line ('select to_char(sysdate,'||''''||'dd/mm/yyyy hh24:mi:ss'||''''||') from dual;');
    dbms_output.put_line ('prompt ********************************');
    --
  end loop;
  dbms_output.put_line ('spool off;');
end;
/
spool off;
undefine bkpuser
undefine bkppass
undefine bkpdir
exit;

