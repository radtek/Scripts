-- os schemas IBOXNET e MEDIAIBOX foram retirados do script pois tem jobs noturnos para executar essa tarefa
WHENEVER SQLERROR EXIT failure;
ALTER SESSION SET CURRENT_SCHEMA=SYSTEM;
set echo ON
set timing ON
set TIME ON
set serveroutput ON
DECLARE
    command VARCHAR2(4000);
BEGIN
    FOR i IN (SELECT idx_owner,
                     idx_name,
                     idx_status
              FROM   ctxsys.ctx_indexes
              WHERE  idx_owner NOT IN ( 'SYS', 'SYSTEM', 'CTXSYS', 'WKSYS',
                                        'WMSYS', 'XDB', 'IBOXNET', 'MEDIAIBOX' )
                     AND idx_status = 'INDEXED'
                     AND idx_type = 'CONTEXT') LOOP
        dbms_output.Put_line('Otimizando indice '
                             ||i.idx_owner
                             || '.'
                             || i.idx_name);

        ctxsys.ctx_ddl.Optimize_index (idx_name => i.idx_owner
                                                   || '.'
                                                   || i.idx_name,
        optlevel => 'FULL'
        ,
        maxtime => 180);
    END LOOP;
END;
/  
