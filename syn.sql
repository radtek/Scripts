select * from dba_synonyms where synonym_name like upper('&syn_Name') and owner like upper('&owner');