select v.pool, round(to_number(p.value) / 1024 / 1024) Total, round(v.bytes / 1024 / 1024) Livre , round((v.bytes / p.value) * 100) pct_free
  from v$sgastat v,
       (select 'shared pool' pool, value from v$parameter where name = 'shared_pool_size'
        union
        select 'large pool' pool , value from v$parameter where name = 'large_pool_size'
        union
        select 'java pool' pool , value from v$parameter where name = 'java_pool_size') p
 where name like '%free memory%'
   and v.pool = p.pool;