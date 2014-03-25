
prompt '** qual objetos envolvidos **'
SELECT  S.sid, S.taddr, S.lockwait, 
		S.status, 
		S.sql_address,
        S.row_wait_obj# RW_OBJ#, 
		S.row_wait_file# RW_FILE#, 
		S.row_wait_block# RW_BLOCK#, 
		S.row_wait_row# RW_ROW#
    FROM v$session S
		 INNER JOIN ( select  l.SID
				      from gv$lock l
					  where (ID1,ID2,TYPE) in (select ID1,ID2,TYPE from gv$lock where request>0)) L
			ON L.SID = S.SID		
 ORDER BY sid;
