prompt informando as informações para ativar o trace a nivel de servico,modulo e action DBMS_MONITOR.SERV_MOD_ACT
prompt para action DBMS_APPLICATION_INFO.ALL_ACTIONS significa todas actions disponiveis para um service/module
prompt para module e action com NULL e empty string, pega todos os service 
prompt 
exec DBMS_APPLICATION_INFO.SET_CLIENT_INFO(&CLIENT_INFO);
exec DBMS_APPLICATION_INFO.SET_MODULE(&MODULE, &action);
undefine action