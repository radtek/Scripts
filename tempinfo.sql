Select a.Tablespace_name, a.Current_Users,
       Round((a.total_blocks * b.block_size)/1024/1024) MB_Segment,
       Round((a.Used_blocks * b.block_size)/1024/1024) MB_Em_Uso,
       Round((a.Free_blocks * b.block_size)/1024/1024) MB_Livre,
       Round((a.Max_blocks * b.block_size)/1024/1024) MB_Maximo, 
       Round((a.Max_used_blocks * b.block_size)/1024/1024) MB_Maximo_usado, 
       Round((a.Max_sort_blocks * b.block_size)/1024/1024) MB_Maximo_Individual, 
	   i.instance_name, i.host_name
  from gv$sort_segment a, dba_tablespaces b, gv$instance i
 where a.tablespace_name = b.tablespace_name
 and i.inst_id = a.inst_id;
 
