# cronatab
#	 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57 * * * * /home/oracle/snap/ilegra_lock.sh > /home/oracle/snap/ilegra_lock.log 2>&1
#
# lock333
# Mata processos que estao trancanco sessoes
# desde que sejam DEDICATED e estejam em status INACTIVE
#

# Inicialização de Variaveis
. /home/oracle/.profile

# Especificar aqui o diretorio onde os logs diarios serao gerados.
DIR_LOG=/home/oracle/snap/logs_lock

#Remove logs com mais de 20dias
find $DIR_LOG -name 'locks_rac*.log' -ctime +30 -exec rm -f {} \;


export TERM=vt100
export NLS_DATE_FORMAT='dd/mm/rrrr hh24:mi:ss';
LOG=${DIR_LOG}/locks_rac_${ORACLE_SID}_`date +'%Y-%m-%d'`.log


clear

{
sqlplus -s sys/sysp650p1@rac8 as sysdba <<fimsql

PROMPT Data e hora da execucao

set serveroutput on;

select sysdate from dual
/

--## Popula tabela de auditoria de locks

Declare
  dtsnap date := sysdate;
Begin

   insert into audit_locks
   Select dtsnap locksnap_date, sb.sid bSid, Pb.spid bspid, Sb.status bstatus, Sb.last_call_et blast_call_et, Sb.username busername,
       nvl(sb.module,sb.program) bproginfo, Sb.sql_id bsql_id, Sb.event bevent,
       s.Sid wSid, P.spid wspid, S.status wstatus, S.last_call_et wlast_call_et, S.username wusername,
       nvl(s.module,s.program) wproginfo, S.sql_id wsql_id, S.event wevent,
       W.Lock_TYpe, W.mode_held, W.mode_requested,
       (Select Owner||'.'||Object_name from dba_objects O where o.object_id = W.lock_id1) Obj_id1,
       (Select Owner||'.'||Object_name from dba_objects O where o.object_id = W.lock_id2) Obj_id2,
       sb.machine bmachine, s.Machine wmachine,
       s.ROW_WAIT_OBJ# wROW_WAIT_OBJ#, s.ROW_WAIT_FILE# wROW_WAIT_FILE#, s.ROW_WAIT_BLOCK# wROW_WAIT_BLOCK#, s.ROW_WAIT_ROW# wROW_WAIT_ROW#
    from Dba_Waiters W, v\$session sb, v\$session s, v\$process P, v\$process Pb
   where s.paddr = p.addr
     and sb.paddr = pb.addr
     and s.sid   = W.WAITING_SESSION
     and sb.sid  = W.HOLDING_SESSION
     and W.MODE_HELD <> 'None';

   Insert into Audit_Locks_Blocking_Sqls
   select /*+ Leading(O) use_Nl(o a b) */
        DISTINCT dtsnap locksnap_date, a.sid, b.sql_id, b.hash_value, b.PLAN_HASH_VALUE, b.buffer_gets, b.disk_reads, b.executions,  b.rows_processed,
        b.USERS_EXECUTING , b.FIRST_LOAD_TIME        ,b.PARSE_CALLS,
        b.VERSION_COUNT,  b.LOADED_VERSIONS, b.OPEN_VERSIONS,
        b.sql_text
    from (Select /*+ no_merge */ HOLDING_SESSION from dba_blockers) o,
         v\$open_cursor a, v\$sqlarea b
   where a.address    = b.address
     and a.hash_value = b.hash_value
     and a.sid        = o.HOLDING_SESSION;

   commit;
end;
/


PROMPT Informacoes da sessao bloqueadora:
set pages 300
set lines 300
col MACHINE for A20 trunc
col USERNAME for A12
col proginfo format a25 trunc
col session_id format 99999 head SID
col status format a1 trunc

col event for a30 trunc
col lock_type for a15 trunc
col mode_held for a20 trunc
col mode_requested for a20 trunc
col Obj_id1 for a40 trunc
col Obj_id2 for a40 trunc
col name for a30
col LOCK_TYPE      for a5
col MODE_HELD      for a12
col MODE_REQUESTED for a12

select l.session_id, s.username, s.machine,  s.status, nvl(s.module,s.program) proginfo,
o.name, w.event, l.LOCK_TYPE, l.MODE_HELD, l.MODE_REQUESTED
from dba_lock l, v\$locked_object v, sys.obj\$ o, v\$session s, v\$session_wait w
where o.obj# = v.object_id
and l.blocking_others='Blocking'
and v.session_id = l.session_id
and v.session_id = s.sid
and s.sid = w.sid
and s.type != 'BACKGROUND'
order by o.name
/

--### Logando mais informacoes (Gediel, 13/06/2012)

Select S.sid, P.spid, S.status, S.last_call_et, S.username, nvl(s.module,s.program) proginfo, S.SQL_ID, S.event, S.SECONDS_IN_WAIT
  from dba_blockers B, v\$session s, v\$process P
 where s.paddr = p.addr
   and s.sid   = b.HOLDING_SESSION
Order by S.sid;

Break On Blocker_Sid Skip 1;

Prompt informacoes das sessoes Bloqueadas (esperando).....

Select sb.sid Blocker_Sid, s.Sid Waiter_Sid, P.spid, S.status, S.last_call_et, S.username, nvl(s.module,s.program) proginfo, S.sql_id, S.event,
       W.Lock_TYpe, W.mode_held, W.mode_requested,
       (Select Owner||'.'||Object_name from dba_objects O where o.object_id = W.lock_id1) Obj_id1,
       (Select Owner||'.'||Object_name from dba_objects O where o.object_id = W.lock_id2) Obj_id2,
       s.ROW_WAIT_OBJ# wROW_WAIT_OBJ#, s.ROW_WAIT_FILE# wROW_WAIT_FILE#, s.ROW_WAIT_BLOCK# wROW_WAIT_BLOCK#, s.ROW_WAIT_ROW# wROW_WAIT_ROW#
  from Dba_Waiters W, v\$session sb, v\$session s, v\$process P
 where s.paddr = p.addr
   and s.sid   = W.WAITING_SESSION
   and sb.sid  = W.HOLDING_SESSION
Order by Blocker_Sid, Waiter_Sid;

PROMPT Data e hora

select sysdate from dual
/

fimsql
} >> $LOG 2>&1

echo "`date` -> Gerado snap no arquivo $LOG"
