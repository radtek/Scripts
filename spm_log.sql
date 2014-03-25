col signature for 9999999999999999999999999999
col sql_text for a60 wrapped

select log.signature, log.BATCH#, sql.sql_id, substr(sql.sql_text, 1, 60) sql_text, sql.executions
from sys.sqllog$ log
	inner join v$sql sql
		on log.signature = sql.exact_matching_signature
where sql_text not like '%IGNORE%'
and upper(sql_text)  not like  '%EXPLAIN%';