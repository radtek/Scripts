/*****************************************************************************\ 
 * TraceGP 5.2.0.40                                                          *
\*****************************************************************************/

ALTER TABLE CAMPO_FORMULARIO_ESTADO DROP CONSTRAINT FK_CAMPO_FORM_ESTADO_02;

ALTER TABLE CAMPO_FORMULARIO_ESTADO ADD  CONSTRAINT FK_CAMPO_FORM_ESTADO_02 
  FOREIGN KEY (FORMULARIO_ID, ESTADO_ID) REFERENCES ESTADO_FORMULARIO (FORMULARIO_ID,ESTADO_ID) ON DELETE CASCADE;


-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '43', 2, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
end;
/
                    
select * from v_versao;
/
