define owner=&owner
select count(1) from dba_objects where owner in ('&owner');
select count(1) from dba_indexes where owner in ('&owner');
select count(1) from dba_constraints where owner in ('&owner');
select count(1) from dba_tables where owner in ('&owner');
select count(1) from dba_sequences where sequence_owner in ('&owner');
select count(1) from dba_triggers where owner in ('&owner');
select count(1) from dba_synonyms where owner in ('&owner');
select count(1) from dba_jobs where log_user in ('&owner');
select count(1) ctd, object_type from dba_objects where owner in ('&owner') group by object_type order by object_type;
undef owner

