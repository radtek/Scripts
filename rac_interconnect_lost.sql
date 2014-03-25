prompt pacote perdidos ou rede altamente congestionada 
prompt pode determinar problemas na interconnect
prompt deve ser menos que 1% do total gc cr/current blocks received
prompt 
SELECT name, SUM(VALUE)
FROM gv$sysstat
WHERE name LIKE 'gc%lost'
OR name LIKE 'gc%received'
OR name LIKE 'gc%served'
GROUP BY name
ORDER BY name;