SELECT shared_pool_size_for_estimate,
	shared_pool_size_factor * 100 size_pct,
	estd_lc_time_saved,
	estd_lc_time_saved_factor * 100 saved_pct,
	estd_lc_load_time,
	estd_lc_load_time_factor * 100 load_pct
FROM v$shared_pool_advice
ORDER BY shared_pool_size_for_estimate;