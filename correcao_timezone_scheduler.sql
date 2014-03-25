SET SERVEROUTPUT ON
DECLARE
    d_STARTDATE TIMESTAMP with time zone;
    d_NEWSTARTDATE TIMESTAMP with time zone;
    V_STARTHOUR VARCHAR2(10);
    v_newStartDate varchar2(30);
    v_timezone_hour VARCHAR2(6);
BEGIN
    DBMS_OUTPUT.ENABLE(NULL);
    
    -- recupera time zone atual da máquina
    SELECT TO_CHAR(SYSTIMESTAMP, 'TZR') INTO V_TIMEZONE_HOUR FROM DUAL;    
    
    --DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE('log_history','90');
    DBMS_SCHEDULER.SET_SCHEDULER_ATTRIBUTE('default_timezone',V_TIMEZONE_HOUR);
    
    -- loop em jobs que possuem time zone diferente do time zone atual da maquina
    FOR CUR_ROW IN  ( SELECT  OWNER, JOB_NAME, START_DATE
                      FROM    DBA_SCHEDULER_JOBS
                      WHERE   TO_CHAR(SYSTIMESTAMP, 'TZR') <> TO_CHAR(NEXT_RUN_DATE, 'TZR'))
                      --AND     REPEAT_INTERVAL IS NOT NULL)
    LOOP    
        -- recupera data inicio
        DBMS_SCHEDULER.GET_ATTRIBUTE(CUR_ROW.OWNER || '.' || CUR_ROW.JOB_NAME, 'START_DATE', d_STARTDATE);
        V_STARTHOUR := TO_CHAR(D_STARTDATE, 'hh24:mi:ss');
        V_NEWSTARTDATE := TO_CHAR(SYSDATE,'dd/mm/yyyy ') || V_STARTHOUR || ' ' || V_TIMEZONE_HOUR;
        DBMS_OUTPUT.PUT_LINE('d_STARTDATE: ' || d_STARTDATE);
        DBMS_OUTPUT.PUT_LINE('v_newStartDate: ' || V_NEWSTARTDATE);
        D_NEWSTARTDATE := to_timestamp_tz(V_NEWSTARTDATE, 'dd/mm/yyyy hh24:mi:ss TZR');
        DBMS_OUTPUT.PUT_LINE('D_NEWSTARTDATE: ' || D_NEWSTARTDATE);       
                       
        -- atribui data inicio anterior reatribuindo time zone atual
        DBMS_SCHEDULER.SET_ATTRIBUTE(cur_row.OWNER || '.' || cur_row.JOB_NAME,'START_DATE',D_NEWSTARTDATE);
        DBMS_OUTPUT.PUT_LINE('Start Date Job ' || cur_row.owner || '.' || cur_row.job_name || ': ' || D_NEWSTARTDATE);  
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('Erro: ' || sqlerrm);
END;
