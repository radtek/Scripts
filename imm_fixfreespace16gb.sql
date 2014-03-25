WHENEVER SQLERROR EXIT FAILURE;
	set serveroutput on size 1000000;
declare
   DTF_TAM_MB number := 16000;
   time_to_sleep number := 200;
   nro_critical  number := null;
   nro_warning   number := null;
   nro_tries     number := 0;
begin
   loop
      nro_tries := nro_tries + 1;
      exit when ((nro_critical = 0 and nro_warning = 0) or nro_tries >= 3);
	  dbms_output.put_line ('Inicio:' || to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') );
      dbms_output.put_line ('****************************************************');
      system.imm$sgt_pkg.prc_testa_folga_tablespaces (nro_warning, nro_critical, true, DTF_TAM_MB );
      system.imm$sgt_pkg.prc_testa_folga_tablespaces (nro_warning, nro_critical, true, DTF_TAM_MB);
      dbms_output.put_line ('Nro de Tablespaces com folga Warning.:'||nro_warning);
      dbms_output.put_line ('Nro de Tablespaces com folga Critical:'||nro_critical);
      dbms_lock.sleep (Time_to_sleep);
      system.imm$sgt_pkg.prc_testa_folga_tablespaces (nro_warning, nro_critical, true, DTF_TAM_MB);
      dbms_output.put_line ('Nro de Tablespaces com folga Warning.:'||nro_warning);
      dbms_output.put_line ('Nro de Tablespaces com folga Critical:'||nro_critical);
      dbms_output.put_line ('****************************************************');
	  dbms_output.put_line ('Final.:' || to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') );
   end loop;
end;
/
