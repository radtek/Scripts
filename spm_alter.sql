prompt ********ATRIBUTOS POSSIVEIS 
prompt - enabled (YES ou NO)
prompt - fixed (YES ou NO)
prompt - autopurge (YES ou NO)
prompt - plan_name (30 caracteres)
prompt - description (500 caracteres)
prompt 

variable cnt number; 
exec :cnt :=DBMS_SPM.ALTER_SQL_PLAN_BASELINE(SQL_HANDLE => &sql_handle, PLAN_NAME => &plan_name, ATTRIBUTE_NAME => '&Attribute',  ATTRIBUTE_VALUE => '&value');
print :cnt			