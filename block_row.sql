select do.object_name
, row_wait_obj#
, row_wait_file#
, row_wait_block#
, row_wait_row#
, dbms_rowid.rowid_create (1, ROW_WAIT_OBJ#, ROW_WAIT_FILE#,
ROW_WAIT_BLOCK#, ROW_WAIT_ROW#)
from v$session s
, dba_objects do
where sid=&sid
and  s.ROW_WAIT_OBJ# = do.OBJECT_ID;