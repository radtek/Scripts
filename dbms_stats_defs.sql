col cascade for a20
col degree for a20
col est_perc for a20
col method_opt for a20
col no_inv for a20
col granu for a20
col autostat for a20

SELECT DBMS_STATS.GET_PARAM('CASCADE') cascade,
DBMS_STATS.GET_PARAM('DEGREE') degree,
DBMS_STATS.GET_PARAM('ESTIMATE_PERCENT') est_perc,
DBMS_STATS.GET_PARAM('METHOD_OPT') method_opt,
DBMS_STATS.GET_PARAM('NO_INVALIDATE') no_inv
DBMS_STATS.GET_PARAM('GRANULARITY') granu
from dual;


