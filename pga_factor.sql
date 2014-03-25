SELECT pga_target_factor,LOW_OPTIMAL_SIZE/1024 low_kb, (HIGH_OPTIMAL_SIZE+1)/1024 high_kb, 
       estd_optimal_executions estd_opt_cnt, 
       estd_onepass_executions estd_onepass_cnt, 
       estd_multipasses_executions estd_mpass_cnt 
  FROM v$pga_target_advice_histogram 
 WHERE  estd_total_executions != 0 
 ORDER BY 1,2; 