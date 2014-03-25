
col group_name format a20
prompt perfil do diskgrupo
SELECT
     ADG.name group_name
    ,AD.reads
    ,AD.writes
    ,(AD.reads + AD.writes) as total_io
    ,round(AD.reads / (AD.reads + AD.writes) * 100) as "%read"
    ,round(AD.writes / (AD.reads + AD.writes) * 100) as "%write"
  FROM 
     v$asm_disk_stat AD
    ,v$asm_diskgroup ADG
 WHERE AD.group_number = ADG.group_number
 ORDER BY ADG.name, AD.disk_number;
 
prompt perfil por tipo, ordenado por leitura
SELECT
 AF.type
,ADG.name group_name
,SUM(AF.cold_reads + AF.hot_reads) tot_reads
,SUM(AF.cold_writes + AF.hot_writes) tot_writes	
FROM 
v$asm_file AF
,v$asm_diskgroup ADG
WHERE AF.group_number = ADG.group_number
AND AF.type IN ('CONTROLFILE','DATAFILE','ONLINELOG','TEMPFILE')
group by AF.type, ADG.name 
ORDER BY tot_reads desc;

prompt perfil por tipo, ordenado por escrita
SELECT
 AF.type
,ADG.name group_name
,SUM(AF.cold_reads + AF.hot_reads) tot_reads
,SUM(AF.cold_writes + AF.hot_writes) tot_writes	
FROM 
v$asm_file AF
,v$asm_diskgroup ADG
WHERE AF.group_number = ADG.group_number
AND AF.type IN ('CONTROLFILE','DATAFILE','ONLINELOG','TEMPFILE')
group by AF.type, ADG.name 
ORDER BY tot_writes desc;