col mount_point for a10
break on report
compute sum of Mb_Total on report;
compute sum of Mb_nao_Oracle on report;
compute sum of Mb_Usado_pelo_DB on report;
compute sum of Mb_Free_no_FS on report;
compute sum of mb_DISP_DB on report;

Select MOUNT_POINT,MB_TOTAL,MB_NAO_ORACLE, PERC_FOLGA_DESEJADA as "%folga desejada",
       round((perc_folga_desejada/100)*mb_total) mb_folga_desejada,
       Mb_Total - Mb_nao_Oracle - round((perc_folga_desejada/100)*mb_total) Mb_Disp_db,
       imm$sgt_pkg.FNC_GET_ORACLE_USAGE(mount_point) Mb_Usado_pelo_DB,
       (Mb_Total - Mb_nao_Oracle - round((perc_folga_desejada/100)*mb_total)) - imm$sgt_pkg.FNC_GET_ORACLE_USAGE(mount_point) Mb_Free_no_FS
from system.imm$sgt_FS_utilizacao a
order by mount_point
/
