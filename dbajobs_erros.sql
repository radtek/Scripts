select data, ctd from (select count(1) ctd, trunc(TIME_STAMP) data from imm$critical_jobs_error_log group by trunc(TIME_STAMP) order by trunc(TIME_STAMP) desc ) where rownum < 30 order by data;

select * from (select * from imm$critical_jobs_error_log order by TIME_STAMP desc ) where rownum < 10 order by TIME_STAMP;