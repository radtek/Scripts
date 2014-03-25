prompt 
prompt default coletado aqui é 7
prompt 
prompt - Levels  = 0  General performance statistics
prompt - Levels  = 5  Additional data:  SQL Statements
prompt - Levels  = 6  plan capture para sqls que excedem pelo menos 1 do thresholds
prompt - Level   = 7  segment statistics
prompt - Levels  = 10 Additional statistics:  Child latches (resource intensive, somente quando recomendado pela oracle)
prompt  

execute statspack.snap(7);
