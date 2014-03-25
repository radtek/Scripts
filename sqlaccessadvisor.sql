VARIABLE task_id NUMBER;
EXECUTE DBMS_ADVISOR.CREATE_TASK ('SQL Access Advisor', 
:task_id, ‘my_first_task’);


-- define o workload para adicionar sqls
EXECUTE DBMS_ADVISOR.CREATE_SQLWKLD(‘my_first_workload’,'This is my first workload');


-- link
EXECUTE DBMS_ADVISOR.ADD_SQLWKLD_REF('my_first_task', 'my_first_workload');


-- adicionado sqls
EXECUTE DBMS_ADVISOR.ADD_SQLWKLD_STATEMENT ( -
   'my_first_workload', 'MONTHLY', 'ROLLUP', priority=>1, executions=>20, -
    username => 'DEMO',  sql_text => ‘SELECT SUM(sales) FROM sales);


-- generate recomendations
EXECUTE DBMS_ADVISOR.EXECUTE_TASK('my_first_task');


-- pegar recomendações
EXECUTE DBMS_ADVISOR.CREATE_FILE(DBMS_ADVISOR.GET_TASK_SCRIPT('my_first_task'), - 
               'ADVISOR_RESULTS', 'script.sql'); 
