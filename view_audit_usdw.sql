prompt retenção de 60 dias controladas por job
set lines 2000
col user_name for a20
col object_type for a20
col owner for a20
col object_name for a30
col sql_text for a100 wrapped
col hostname for a20
col instance for a5
col ip_address for a20
col ddl_type for a20
select * from system.DDL_ACTIONS;