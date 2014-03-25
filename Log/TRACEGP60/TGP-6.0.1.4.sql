/*****************************************************************************\ 
 * TraceGP 6.0.1.4                                                           *
\*****************************************************************************/
--define CS_TBL_DAT = &TABLESPACE_DADOS;
--define CS_TBL_IND = &TABLESPACE_INDICES;
-------------------------------------------------------------------------------

begin
  for obj in (select h.* from HORATRABALHADA h, tarefa t, usuario u where h.tarefa = t.id and t.situacao = 1 and u.usuarioid = h.responsavel) loop
    update tarefa set situacao = 2 where id = obj.tarefa;
    update tarefa set iniciorealizado = (select min(h.datatrabalho) from horatrabalhada h where h.tarefa = obj.tarefa) where id = obj.tarefa;
    update tarefa set horasrealizadas = (select sum(h.minutos) from horatrabalhada h where h.tarefa = obj.tarefa) where id = obj.tarefa;
    commit;
  end loop;
end;
/

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------
insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.1', '04', 4, 'Aplicação de Patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/

select * from v_versao;
/





