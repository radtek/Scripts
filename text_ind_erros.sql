col ERR_TEXT for a200
select * from (select * from ctxsys.CTX_INDEX_ERRORS order by ERR_TIMESTAMP desc) where rownum < 10 order by ERR_TIMESTAMP;

Select owner, table_name, INDEX_NAME, INDEX_TYPE, TABLE_NAME, DOMIDX_STATUS, DOMIDX_OPSTATUS
from dba_indexes
where DOMIDX_OPSTATUS <> 'VALID';