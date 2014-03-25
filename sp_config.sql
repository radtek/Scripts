prompt 
prompt Although Statspack captures all segment statistics, it reports only the following statistics that exceed one of the predefined threshold parameters:
prompt 
prompt Number of logical reads on the segment. The default is 10,000. 
prompt Number of physical reads on the segment. The default is 1,000. 
prompt Number of buffer busy waits on the segment. The default is 100. 
prompt Number of row lock waits on the segment. The default is 100. 
prompt Number of ITL waits on the segment. The default is 100. 
prompt Number of global cache consistent read blocks served (RAC only). The default is 1,000. 
prompt Number of global cache current blocks served (RAC only). The default is 1,000. 
prompt 
prompt 
select * from STATS$STATSPACK_PARAMETER;
prompt
prompt 
SELECT * FROM stats$level_description ORDER BY snap_level;
prompt
