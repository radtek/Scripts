SELECT RTRIM (LPAD (' ', 2 * LEVEL) ||
RTRIM (nvl(operation, '')) || ' ' ||
RTRIM (nvl(options, '')) || ' ' ||
nvl(object_name, '')) query_plan,
cost,
cardinality, 
other_tag
FROM plan_table
CONNECT BY PRIOR id = parent_id
START WITH id = 0;