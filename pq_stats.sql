SELECT dfo_number, tq_id, server_Type, MIN (num_rows),
MAX (num_rows),count(*) dop, COUNT (DISTINCT instance) no_of_instances
FROM v$pq_tqstat
GROUP BY dfo_number, tq_id, server_Type
ORDER BY dfo_number, tq_id, server_type DESC;