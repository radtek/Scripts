col msg format a300

select * from (select * from imm$sgt_log where tp= 'E' order by DT desc) where rownum < 100;