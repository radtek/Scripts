col JOB_NAME for a30
col RESOURCE_CONSUMER_GROUP for a30
col JOB_NAME for a30
col SESSION_ID for a20
col SLAVE_PROCESS_ID for a20
col RUNNING_INSTANCE for a20
col ELAPSED_TIME for a20
col CPU_USED for a20
col LOG_ID for 999999999

SELECT 
 JOB_NAME
 ,SESSION_ID
 ,SLAVE_PROCESS_ID
 ,SLAVE_OS_PROCESS_ID
 ,RUNNING_INSTANCE
 ,RESOURCE_CONSUMER_GROUP
 ,ELAPSED_TIME
 ,CPU_USED
 ,LOG_ID
FROM DBA_SCHEDULER_RUNNING_JOBS;
