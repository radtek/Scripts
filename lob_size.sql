set serveroutput on 

declare 
TOTAL_BLOCKS number; 
TOTAL_BYTES number; 
UNUSED_BLOCKS number; 
UNUSED_BYTES number; 
LAST_USED_EXTENT_FILE_ID number; 
LAST_USED_EXTENT_BLOCK_ID number; 
LAST_USED_BLOCK number; 

begin 
dbms_space.unused_space('&owner','&lob_segment_name','LOB', 
TOTAL_BLOCKS, TOTAL_BYTES, UNUSED_BLOCKS, UNUSED_BYTES, 
LAST_USED_EXTENT_FILE_ID, LAST_USED_EXTENT_BLOCK_ID, 
LAST_USED_BLOCK); 

dbms_output.put_line('SEGMENT_NAME = <LOB SEGMENT NAME>'); 
dbms_output.put_line('-----------------------------------'); 
dbms_output.put_line('TOTAL_BLOCKS = '||TOTAL_BLOCKS); 
dbms_output.put_line('TOTAL_BYTES = '||TOTAL_BYTES); 
dbms_output.put_line('UNUSED_BLOCKS = '||UNUSED_BLOCKS); 
dbms_output.put_line('UNUSED BYTES = '||UNUSED_BYTES); 
dbms_output.put_line('LAST_USED_EXTENT_FILE_ID = '||LAST_USED_EXTENT_FILE_ID); 
dbms_output.put_line('LAST_USED_EXTENT_BLOCK_ID = '||LAST_USED_EXTENT_BLOCK_ID); 
dbms_output.put_line('LAST_USED_BLOCK = '||LAST_USED_BLOCK); 

end; 
/