prompt 
prompt informe o sql_id para carregar no sql plan managemente, planos carregados são automaticamente aceitáveis, mas não fixos
prompt 
SET SERVEROUTPUT ON
DECLARE
  l_plans_loaded  PLS_INTEGER;
BEGIN
  l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache(
    sql_id => '&sql_id');
    
  DBMS_OUTPUT.put_line('Plans Loaded: ' || l_plans_loaded);
END;
/
