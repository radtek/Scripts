  CREATE OR REPLACE PROCEDURE "SYSTEM"."PRC_SLOW_SQLS" (p_sec_limit in number, p_kill_sessions in boolean default FALSE) is
   Cursor c1 is
   select distinct a.sid, a.serial#, a.status, a.last_call_et, a.logon_time, a.sql_hash_value, b.sql_text, b.sql_id, b.plan_hash_value, sysdate dt_snap
     from v$session A, v$sql B
    where A.username = 'SIGMA'
      and A.PROGRAM = 'w3wp.exe'
      AND A.STATUS = 'ACTIVE'
      and A.SQL_HASH_VALUE = B.HASH_VALUE
      and A.last_call_et > (p_sec_limit)
    Order by 1,2;

   ---
   cursor c2 (p_hash in number) is
     select sql_text, piece
       from  v$sqltext
      where HASH_VALUE     = p_hash
        and trim(sql_text) is not null
      order by PIECE;

   v_existe number;
Begin
    For C in C1
    Loop
      Insert into SLOW_SESSIONS_LOG (
       INST_ID,
       SID,
       SERIAL#,
       STATUS,
       LAST_CALL_ET,
       LOGON_TIME,
       SQL_HASH_VALUE,
       SQL_TEXT,
       SQL_ID,
       PLAN_HASH_VALUE,
       DT_SNAP)
       Values (
           Null,
           C.sid,
           C.SERIAL#,
           C.STATUS,
           c.LAST_CALL_ET,
           c.LOGON_TIME,
           c.SQL_HASH_VALUE,
           c.SQL_TEXT,
           c.SQL_ID,
           c.PLAN_HASH_VALUE,
          Sysdate);
       --------
       v_existe := null;
       Select Max(1)
          into v_existe
         from SLOW_SQLS_TEXT
         where hash_value = c.SQL_HASH_VALUE;

       if (v_existe is null) then
           for T in c2 (c.SQL_HASH_VALUE)
           Loop
              Insert into SLOW_SQLS_TEXT (hash_value, sql_text , line_order) Values ( C.sql_hash_value, T.sql_text, T.piece);
           End loop;
       end if;
    if (p_kill_sessions) Then
         dbms_output.put_line ('Alter system kill session '||''''||C.sid||','||C.serial#||'''');
         execute immediate ('Alter system kill session '||''''||C.sid||','||C.serial#||'''');
    end if;
   End loop;
End PRC_SLOW_SQLS;
