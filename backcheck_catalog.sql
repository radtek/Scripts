Select Cat.*, nvl(C.Enabled,'N') Check_Enabled, C.db_name Check_name
  from (Select A.dbid, A.name,
               Round(sum(b.OUTPUT_BYTES)/1024/1024) tam_mb,
               Round(sum(b.ELAPSED_SECONDS)/60) time_min,
               Max(end_time) Last_End_Time,
               Count(*) Nro_Bkps_hoje
          from Rc_database A, rc_rman_backup_job_details B
         Where A.db_key = B.db_key
           and B.end_time > trunc(sysdate)
           and B.INPUT_TYPE like 'DB%%'
           and B.STATUS in ('COMPLETED WITH WARNINGS','COMPLETED')
         group by A.dbid, A.name
      ) Cat,
      IMM$CHECK_BKP_CFG c
 where cat.dbid (+) = C.db_id
   and cat.name (+) = C.db_name
 order by Cat.Last_End_Time