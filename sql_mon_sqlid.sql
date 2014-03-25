SELECT ROUND(elapsed_time    /1000000)     AS "Elapsed (s)",
     ROUND(cpu_time             /1000000,3)   AS "CPU (s)",
     ROUND(queuing_time         /1000000,3)   AS "Queuing (s)",
     ROUND(application_wait_time/1000000,3)   AS "Appli wait (s)",
     ROUND(concurrency_wait_time/1000000,3)   AS "Concurrency wait (s)",
     ROUND(cluster_wait_time    /1000000,3)   AS "Cluster wait (s)",
     ROUND(user_io_wait_time    /1000000,3)   AS "User io wait (s)",
     ROUND(physical_read_bytes  /(1024*1024)) AS "Phys reads (MB)",
     ROUND(physical_write_bytes /(1024*1024)) AS "Phys writes (MB)",
     buffer_gets                              AS "Buffer gets",
     ROUND(plsql_exec_time/1000000,3)         AS "Plsql exec (s)",
     ROUND(java_exec_time /1000000,3)         AS "Java exec (s)"
     FROM v$sql_monitor
WHERE sql_id = '&sqlid';
