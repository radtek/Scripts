/*****************************************************************************\
* TraceGP patch 7 (6.0.0)                                                     *
\*****************************************************************************/

-- Add/modify columns 
alter table RELAT_DATASET_CAMPO modify DATASET_ID NUMBER(12);
-- Add/modify columns 
alter table RELAT_DATASET_PARAMETRO modify DATASET_ID NUMBER(12);
-- Add/modify columns 
alter table RELAT_DATASET modify ID NUMBER(12);
-- Add/modify columns 
alter table RELAT_RELATORIO modify DATASET_ID NUMBER(12);
-- Add/modify columns 
alter table RELAT_RELATORIO_COMPONENTE modify DATASET_ID NUMBER(12);
--
alter table log_tracegp modify nome_metodo varchar2(500);
alter table log_tracegp modify argumentos_metodo varchar2(4000);
alter table log_tracegp modify nome_class varchar2(500);
alter table log_tracegp modify message varchar2(4000);
alter table log_tracegp modify exception_class varchar2(500);
alter table log_tracegp modify stacktrace varchar2(4000);
alter table log_tracegp modify message_cause varchar2(4000);
alter table log_tracegp modify exception_class_cause varchar2(500);
alter table log_tracegp modify stacktrace_cause varchar2(4000);

insert into tela (TELAID, NOME, URL, VISIVEL, GRUPOID, ORDEM, CODIGO, SUBGRUPO, ATALHO)
       values (478, 'bd.tela.datasets', 'RelatDataset.do?command=listagemAction', 
               'S', 6, 21, 'RELAT_DATASET', 'PRIMEIRO', 'N');
               
update regras_tipo_entidade e
   set e.nome_tabela = 'mv_custo_lancamento'
 where id = 13;
 
insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
       values (664, 'label.prompt.tituloArvoreCusto', 'CUSTO_RECEITA_TITULO', 2, 'Y', '', 13, null, 'N');
insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
       values (10, 'contarDistinct', 'label.prompt.contarDistinto');
       
commit;
/

--
create or replace function f_dias_uteis_entre(pid_inicio date, pid_fim date) return number is
  ld_data date;
  ln_dias number:=0;
  max_data date;
begin
   max_data := to_date('99991231','yyyymmdd');
   ld_data := pid_inicio;
   while ld_data <= pid_fim loop
      if to_char(ld_data,'D') not in ('1','7') then
        ln_dias := ln_dias + 1;
      end if;
      
      if ld_data >= max_data then 
         EXIT;
      end if;
      
      ld_data := ld_data + 1;
   end loop;
   return ln_dias;
end;
/

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------
begin
  pck_processo.pRecompila;
  commit;
end;
/

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '07', 3, 'Aplicação de patch (P2)');
commit;
/
                    
select * from v_versao;
/
