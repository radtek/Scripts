define mview_name=&mview_name








FROM DBA_REFRESH_CHILDREN 
WHERE NAME LIKE UPPER('%&mview_name%')
AND RNAME LIKE UPPER('%&Group_Name%');
undefine mview_name



prompt Para excluir em um grupo use (drop remove automatico):
prompt		exec DBMS_REFRESH.SUBTRACT('SUAT_REFRESH_GROUP','TRR_TIPO_COBRANCA');promp