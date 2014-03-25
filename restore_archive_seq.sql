
select HXFIL File_num,substr(HXFNM,1,40) File_name,
  FHTNM TABLESPACE_NAME ,FHRBA_SEQ Sequence                    
 from X$KCVFH
 order by Sequence;  