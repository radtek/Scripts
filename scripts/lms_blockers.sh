root:
	r007lms04

CRIADO EM 13/02/2014 - THIAGO LEITE

DEMANDA DO TICKET 1077825:
Workaround automatizado criado para o LMS, devido a um bug nao mapeado no pool de conexoes do OAS. O problema ocorre nas seguintes maquinas:
- lx-swlms04
- lx-swlms05
- lx-swlms06
- lx-swlms08
- lx-swlms09
Um sessao idle segura locks infinitamente bloqueando outras sessoes e mesmo depois do DBA executar o kill na sessao causadora outras sessoes assumem seu lugar e seguem com o mesmo comportamento bloqueador.

PROCEDIMENTO:
1) Audita sessoes
	-> Conexao realizada com o usuario SYSTEM
	-> Procura por sessões bloqueadoras do usuário LMS_PD_USER partindo do host onde e executado o shell, que estejam idle por mais de 5 minutos e bloqueando mais 2 outras sessoes.
	-> Insere informações das sessoes envolvidas na tabela SYSTEM.ILG_LMS_BLOCKERS.
2) Restart do container
	-> Caso encontre uma situação de block então o container do LMS é restartado com o script /home/oracle/scripts/rlms.sh
	-> Para limitar o numero de servidores down ao mesmo tempo existe um processo de serialização onde é feito um checagem na tabela "SYSTEM"."ILG_LMS_RESTART"
	para verificar se já existe servidores sendo restartados. Inicialmente estamos limitando em 2 servidores em processo de restart do container em paralelo.
	-> Para aumentar ou diminuir o numero de servidores down paralelos basta inserir um id sequencial + null ou deletar o ultimo registro da "SYSTEM"."ILG_LMS_RESTART".
3) Logs
	-> Para mais informacoes sobre as sessoes auditadas consulta a tabela 
	-> Para dia e gerado um arquivo de log com o output do script em /home/oracle/ilegra/monitor_blocks/logs
	-> Script deve ficar em /home/oracle/ilegra/monitor_blocks

AGENDADO NA CRONTAB:
5 * * * * /home/oracle/ilegra/monitor_blocks/lms_blockers.sh

Requisitos(criado):
	-> tabela de log:
	 CREATE TABLE "SYSTEM"."ILG_LMS_BLOCKERS"
	  (    "HOLDER" NUMBER,
		   "SID" NUMBER,
		   "SERIAL#" NUMBER,
		   "ID1" NUMBER,
		   "ID2" NUMBER,
		   "LMODE" VARCHAR2(40),
		   "REQUEST" VARCHAR2(40),
		   "TYPE" VARCHAR2(2),
		   "CTIME" NUMBER,
		   "SQL_ID" VARCHAR2(13),
		   "PREV_SQL_ID" VARCHAR2(13),
		   "STATUS" VARCHAR2(8),
		   "EVENT" VARCHAR2(64),
		   "LAST_CALL_ET_SEG" NUMBER,
		   "LOGON_TIME" DATE,
		   "TRASACTION_START_TIME" VARCHAR2(20),
		   "USED_UREC" NUMBER,
		   "DATA_HORA" DATE,
		   "WAIT_CLASS" VARCHAR2(64),
		   "MACHINE" VARCHAR2(64), 
		   "CTD" NUMBER
	  ) 
	 TABLESPACE "USERS";

	-> tabela controle restart:
		CREATE TABLE "SYSTEM"."ILG_LMS_RESTART"
		( 
			"ID" NUMBER,
			FLAG VARCHAR(100)
		) 
		TABLESPACE "USERS";

	-> DML máximo de servidores
		delete from "SYSTEM"."ILG_LMS_RESTART";
		INSERT INTO "SYSTEM"."ILG_LMS_RESTART" VALUES(1, NULL);
		INSERT INTO "SYSTEM"."ILG_LMS_RESTART" VALUES(2, NULL);
		commit;
	
Script lms_blockers.sh:
#################################################################################################################
#
#CRIADO EM 13/02/2014 - THIAGO LEITE
#
#Demanda do Ticket 1077825:
#Workaround automatizado criado para o LMS, devido a um bug nao mapeado no pool de conexoes do OAS. O problema ocorre nas seguintes maquinas:
#  - lx-swlms04
#  - lx-swlms05
#  - lx-swlms06
#  - lx-swlms08
#  - lx-swlms09
#Um sessao idle segura locks infinitamente bloqueando outras sessoes e mesmo depois do DBA executar o kill na sessao causadora outras sessoes assumem seu lugar
# e seguem com o mesmo comportamento bloqueador.
#
#Procedimento:
#  1) Audita sessoes
#       -> Conexao realizada com o usuario SYSTEM
#       -> Procura por sessÃµbloqueadoras do usuÃ¡o LMS_PD_USER partindo do host onde e executado o shell, que estejam idle por mais de 5 minutos e bloqueando ma
# mais  2 outras sessoes.
#       -> Insere informaÃ§s das sessoes envolvidas na tabela SYSTEM.ILG_LMS_BLOCKERS.
#  2) Restart do container
#       -> Caso encontre uma situaÃ§ de block entÃ£o container do LMS Ã©estartado com o script /home/oracle/scripts/rlms.sh
#		-> Para limitar o numero de servidores down ao mesmo tempo existe um processo de serialização onde é feito um checagem na tabela "SYSTEM"."ILG_LMS_RESTART"
#		para verificar se já existe servidores sendo restartados. Inicialmente estamos limitando em 2 servidores em processo de restart do container em paralelo.
#		-> Para aumentar ou diminuir o numero de servidores down paralelos basta inserir um id sequencial + null ou deletar o ultimo registro da "SYSTEM"."ILG_LMS_RESTART".
#  3) Logs
#       -> Para mais informacoes sobre as sessoes auditadas consulta a tabela
#       -> Para dia e gerado um arquivo de log com o output do script em /home/oracle/ilegra/monitor_blocks/logs
#       -> Script deve ficar em /home/oracle/ilegra/monitor_blocks
#
#Agendado na crontab:
#5 * * * * /home/oracle/ilegra/monitor_blocks/lms_blockers.sh
#
######################################################################################################################

. /home/oracle/.bash_profile

# Define se deve fazer o restart do container, aceita 0 para false e 1 para true
RESTART_CONTAINER=0

# Logon no banco de dados
USER=system
PASS=mp650p1
TNS_ALIAS=TNT_SCAN

# logs de execucao do script
DIR_LOG=/home/oracle/ilegra/monitor_blocks/logs
LOG_FILE=$DIR_LOG/`date '+%m%d%y'`.log

{

restart()
{

		echo "******* INICIO RESTART DO CONTAINER **********"
		
		RESTART_LIBERADO=0
		
		echo "-> Verifica se pode fazer o restart, pois existe um limite de servidores down, caso esteja liberado faz o lock do registro"
		sqlplus -S $USER/$PASS@$TNS_ALIAS <<EOF
spool output.txt
set feedback off
set serveroutput on
DECLARE
	CURSOR c_restart IS
		select id from "SYSTEM"."ILG_LMS_RESTART" WHERE FLAG IS NULL for update skip locked;
		
	reg_restart c_restart%ROWTYPE;
BEGIN
	OPEN c_restart;
	
	FETCH c_restart INTO reg_restart;
	
	IF c_restart%ROWCOUNT > 0 THEN 
		UPDATE "SYSTEM"."ILG_LMS_RESTART"
		SET FLAG = SYS_CONTEXT('USERENV','HOST')
		WHERE ID = reg_restart.id;
	
		commit;
		
		dbms_output.put_line('1');
	END IF;
	
	CLOSE c_restart;	
END;
/
spool off
quit
EOF

		echo "-> Conteudo do arquivo output.txt"
		cat output.txt

		echo "-> Coleta na variavel"
		RESTART_LIBERADO=`cat output.txt`
		echo $RESTART_LIBERADO

		echo "-> Remover arquivo output.txt"
		rm -f output.txt
		
		if [ $RESTART_LIBERADO == 1 ]; then
			echo "-> Realizando restart container"
			#/home/oracle/scripts/rlms.sh
			
		
			echo "-> Restart finalizado libera o lock do registro"
			sqlplus -S $USER/$PASS@$TNS_ALIAS <<EOF
spool output.txt
set feedback off
set serveroutput on
DECLARE
	CURSOR c_restart IS
		select id from "SYSTEM"."ILG_LMS_RESTART" WHERE FLAG = SYS_CONTEXT('USERENV','HOST');
		
	reg_restart c_restart%ROWTYPE;
BEGIN
	OPEN c_restart;
	
	FETCH c_restart INTO reg_restart;
	
	IF c_restart%ROWCOUNT > 0 THEN
		UPDATE "SYSTEM"."ILG_LMS_RESTART"
		SET FLAG = NULL
		WHERE ID = reg_restart.id;
	
		commit;
		
		dbms_output.put_line('OK');
	END IF;
	
	CLOSE c_restart;	
END;
/
spool off
quit
EOF
				
				echo "-> Conteudo do arquivo output.txt"
				cat output.txt

				echo "-> Coleta na variavel"
				RESTART_LIBERADO=`cat output.txt`
				echo $RESTART_LIBERADO

				echo "-> Remover arquivo output.txt"
				rm -f output.txt		
		fi		

		echo "******* FINAL RESTART DO CONTAINER **********"
		echo " "
		echo " "
}

audit_sessions()
{


		echo "*********** INICIO AUDIT SESSIONS *************"

		echo "-> Executar consulta e insert que gera log de sessoes"
		sqlplus -S $USER/$PASS@$TNS_ALIAS <<EOF
spool output.txt
set feedback off
set serveroutput on

BEGIN
		INSERT INTO SYSTEM.ILG_LMS_BLOCKERS
		WITH blocks as
		(
				SELECT /*+ leading(l) materialize */
						  DECODE(l.request,0,1,0) Holder,
						  s.sid sid,
						  s.serial#,
						  id1,
						  id2,
						  decode(lmode,1,'null',2,'RS',3,'RX',4,'S',5,'SRX',6,'X',0,'NONE',lmode) lmode,
						  decode(l.request,1,'null',2,'RS',3,'RX',4,'S',5,'SRX',6,'X',0,'NONE',request) request,
						  l.type,
						  ctime,
						  s.sql_id,
						  s.prev_sql_id,
						  s.status,
						  s.event,
						  s.last_call_et as last_call_et_seg,
						  s.logon_time,
						  t.start_time trasaction_start_time,
						  t.used_urec,
						  sysdate as data_hora,
						  s.wait_class,
						  s.machine,
						  count(1) over () ctd
				FROM v\$lock l,
						 v\$session s,
						 v\$transaction t
				WHERE (l.id1, l.id2, l.type) IN (SELECT id1, id2, type FROM V\$LOCK WHERE request>0)
				  and l.sid = s.sid
				  and s.username = 'LMS_PD_USER'
				  and s.saddr = t.ses_addr (+)
		)
		SELECT *
		FROM blocks
		WHERE EXISTS(SELECT 1  -- se tiver um blocker entao loga
								 FROM blocks
								 WHERE  wait_class = 'Idle'
										and last_call_et_seg/60 >= 5
										and machine = SYS_CONTEXT('USERENV','HOST')
										and Holder = 1
										and ctd >= 3 -- holder + 2 waiters
								);

		IF (SQL%ROWCOUNT > 0) THEN
				dbms_output.put_line('1');
		ELSE
				dbms_output.put_line('0');
		END IF;
END;
/

spool off
quit;
EOF
		echo "-> Conteudo do arquivo output.txt"
		cat output.txt

		echo "-> Coleta na variavel"
		RESTART_CONTAINER=`cat output.txt`
		echo $RESTART_CONTAINER

		echo "-> Remover arquivo output.txt"
		rm -f output.txt

		echo "*********** FINAL AUDIT SESSIONS *************"
		echo " "
		echo " "
}


date '+-------------------- INICIO AUDITORIA SESSOES DATE: %m/%d/%y TIME:%H:%M:%S-------------------------------'
echo " "
echo " "

echo "-> Audita sessoes bloqueadoras e idle por mais de 5 minutos com locks e bloqueando mais de 2 sessoes deste host "
audit_sessions


echo "-> Verificar se precisa fazer o restart do container"
if [ $RESTART_CONTAINER == 1 ]; then
		restart
fi


date '+-------------------- FINAL AUDITORIA SESSOES DATE: %m/%d/%y TIME:%H:%M:%S-------------------------------'
}>>$LOG_FILE 2>&1
								  