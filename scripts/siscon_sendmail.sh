########################################################################
# Enviar por e-mail um alerta caso tenha sessoes do siscon3 a mais de 12 horas ativas
# Solicitação: Julio Fonseca Ticket: 7775
# 13.11.2013
# crontab
#       * 8,20 * * * /usr/local/oracle/oracledba/backup/siscon_sendmail.sh
#
########################################################################


# define parametros
USER=system
PASS=billmanager
ALIAS=orafcobmia
DESTINO=gazlinux-logs@corp.terra.com.br
#DESTINO=Thiago.Leite.ilegra@terc.terra.com.br
DATE="`date '+%Y%m%d%H%M%S'`"
LOG=/usr/local/oracle/oracledba/logs/siscon_sessao_pendurada_$DATE.log

{
echo '**************** INICIO $DATE *****************************'
lista_sessoes()
{
        echo
        echo '************ LISTAR SESSOES PENDURADAS A MAIS DE 12 HORAS ************'
        echo

sqlplus -S -M "HTML ON TABLE 'BORDER="2"'" $USER/$PASS@$ALIAS <<EOF
spool /tmp/siscon.txt
set echo off
alter session set NLS_DATE_FORMAT='dd/mm/rrrr hh24:mi:ss';
col MACHINE for a30 justify left
col OSUSER for a20  justify left
col PROGRAM for a20  justify left
col USERNAME for a10 justify left
col STATUS for a8   justify left
col sid format 999999999
col event for a30
col sql_id for a14 justify right
col Idle_min for 9999999999999 justify right
col SQL for a100
set trimspool on
set lines 2000

prompt
prompt
prompt ***** UM OU MAIS PROCESSOS DO SISCON ULTRAPASSARAM O TEMPO LIMITE DE CONEXÃO COM O BANCO DE DADOS. *****
prompt
select a.inst_id, a.sid,a.serial#,a.username, a.last_call_et/60 Idle_min,a.sql_id, a.osuser,a.machine,a.program,a.status,a.logon_time, a.event, substr(s.sql_text, 1, 100) as SQL
from gv\$session a,
         gv\$sql s
where a.username is not null
  and a.status = 'ACTIVE'
  and a.username = 'SISCON3'
  and a.sql_id = s.sql_id(+)
  and a.inst_id = s.inst_id(+)
  and a.last_call_et/60 >= 720 -- 12 horas
/
spool off
quit
EOF

        echo arquivo gerado, conteudo:
        echo "<html>" > /tmp/siscon.html
        cat /tmp/siscon.txt >> /tmp/siscon.html
        echo '************ FIM LISTAR SESSOES PENDURADAS A MAIS DE 12 HORAS ************ '
        echo
        echo

}

enviar_email()
{

        echo '************ ENVIA EMAIL ************'
        TITLE="Siscon BD: Tempo limite de conexão excedido - $DATE"

        /usr/local/oracle/oracledba/backup/SendEmail -f oracledba@corp.terra.com.br -t $DESTINO -s smtp.corp.terra.com.br -V -u "$TITLE" -m "`cat /tmp/siscon.html`"


        echo '************ FIM ENVIA EMAIL ************ '
}

lista_sessoes


STATUS=`grep "no rows selected" /tmp/siscon.txt  | wc -l`

if [ $STATUS -eq 0 ]
then
        enviar_email
        echo
fi
echo '**************** FINAL $DATE *****************************'
}&>$LOG

exit
         