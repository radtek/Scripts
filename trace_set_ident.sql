prompt informe o identificador para depois ativar o trace ou coleta de stats
prompt
EXEC DBMS_SESSION.set_identifier(client_id => '&ident');
