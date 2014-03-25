SELECT name,
            detected_usages detected, 
            total_samples   samples,
            currently_used  used, 
            to_char(last_sample_date,'MMDDYYYY:HH24:MI') last_sample,
            sample_interval interval
FROM dba_feature_usage_statistics
where currently_used = 'TRUE';