prompt chegar datafiles se assinc io est� ativado
prompt se necess�rio ativar e direct io tb
prompt 

SELECT asynch_io, COUNT( * )
FROM v$iostat_file
WHERE filetype_name in ( 'Data File', 'Temp File')
GROUP BY asynch_io
/