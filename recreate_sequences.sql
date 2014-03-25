set pages 1000
set trimspool on
def owner=&owner

select 'DROP SEQUENCE ' || SEQUENCE_OWNER || '.' || SEQUENCE_NAME ||  ';'
from dba_sequences
where sequence_owner = upper('&owner');

select 'CREATE SEQUENCE ' || SEQUENCE_OWNER || '.' || SEQUENCE_NAME || 
       ' START WITH ' || TO_CHAR(LAST_NUMBER + 1) || 
       ' INCREMENT BY ' || TO_CHAR(INCREMENT_BY) 
       ' MINVALUE ' || TO_CHAR(MIN_VALUE) || 
       ' MAXVALUE ' || TO_CHAR(MAX_VALUE) ||
       DECODE(CYCLE_FLAG, 'Y', ' CYCLE', 'N', ' NOCYCLE') || 
       CASE WHEN CACHE_SIZE > 0 THEN ' CACHE ' || TO_CHAR(CACHE_SIZE) ELSE ' NOCACHE' END ||
       DECODE(ORDER_FLAG, 'Y', ' ORDER', 'N', ' NOORDER') 
       ||  ';'
from dba_sequences
where sequence_owner = upper('&owner');

undef owner