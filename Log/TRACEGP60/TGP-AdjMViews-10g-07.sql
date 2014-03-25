/******************************************************************************\
* Roteiro para ajustes após importação de um dump (10g)                        *
* Autor: Charles Falcão                     Data de Publicação: 16/Jun/2009    *
\******************************************************************************/

declare
  lv_comando varchar2(500);
begin
   for obj in (select * from user_objects
               where object_name like 'MV_%'
                 and object_type = 'MATERIALIZED VIEW') loop
       lv_comando := 'drop materialized view ' || obj.object_name;
       execute immediate lv_comando;
   end loop;
   
   for obj in (select * from user_objects
               where object_name like 'MV_%'
                 and object_type = 'VIEW') loop
       lv_comando := 'drop view ' || obj.object_name;
       execute immediate lv_comando;
   end loop;
   
   for tbl in (select * from user_tables
               where table_name like 'MV_%') loop
       lv_comando := 'drop table ' || tbl.table_name;
       execute immediate lv_comando;
   end loop;
end;
/

--------------------------------------------------------------------------------
-- Remove MATERIALIZED VIEW e MATERIALIZED VIEW LOGS
--------------------------------------------------------------------------------
drop materialized view log on custo_lancamento; 
drop materialized view log on custo_entidade; 
drop materialized view log on custo_receita;
drop materialized view log on usuario; 
drop materialized view log on valor_hora_usuario; 
drop materialized view log on tipoprofissional;

--------------------------------------------------------------------------------
-- MATERIALIZED VIEW LOGS
--------------------------------------------------------------------------------
create materialized view log on custo_lancamento 
       with rowid, (custo_entidade_id, tipo, situacao, data, valor_unitario, 
                    quantidade, valor, usuario_id, data_alteracao)
       including new values;
create materialized view log on custo_entidade 
       with rowid, (tipo_entidade, entidade_id, custo_receita_id, titulo, 
                    tipo_despesa_id, forma_aquisicao_id, unidade, motivo)
       including new values;
create materialized view log on custo_receita
       with rowid, (tipo, titulo, vigente, id_pai)
       including new values;
create materialized view log on usuario 
       with rowid, (tipo_profissional_id)
       including new values;
create materialized view log on valor_hora_usuario 
       with rowid, (data_inicio_valor_hora, valor_hora, usuario_id)
       including new values;
create materialized view log on tipoprofissional
       with rowid, (vigente, valorhora)
       including new values;

--------------------------------------------------------------------------------
-- MATERIALIZED VIEWS & VIEWS 
--------------------------------------------------------------------------------
-- Materialized View mv_custo_lancamento
create materialized view MV_CUSTO_LANCAMENTO refresh fast on commit as
select cr.rowid CR_ROWID, cl.rowid CL_ROWID, ce.rowid CE_ROWID,
       cr.id CUSTO_RECEITA_ID, cr.tipo CUSTO_RECEITA_TIPO, cr.titulo CUSTO_RECEITA_TITULO,
       ce.tipo_entidade TIPO_ENTIDADE, ce.entidade_id ENTIDADE_ID,
       ce.id CUSTO_ENTIDADE_ID, ce.titulo DESP_TITULO,
       cl.situacao SITUACAO, cl.tipo TIPO_LANCAMENTO, cl.valor VALOR,
       cl.data DATA, cr.tipo || cl.tipo CONTABILIZAR_EM
	   ,cl.tipo_lancamento_id TIPO_LANCAMENTO_ID,
     cl.id id
  from custo_entidade   ce,
       custo_receita    cr,
       custo_lancamento cl
 where ce.custo_receita_id  = cr.id
   and cl.custo_entidade_id = ce.id;
--------------------------------------------------------------------------------
-- Materialized View mv_valor_hora_simplificada   
create materialized view mv_valor_hora_simplificada refresh fast on commit as       
select u.rowid   U_ROWID,
       vhu.rowid VHU_ROWID,
       tp.rowid  TP_ROWID,
       usuarioid USUARIO_ID, 
       nvl(vhu.data_inicio_valor_hora,to_date('01011900','ddmmyyyy')) DATA_INICIO,
       nvl(vhu.valor_hora,nvl(tp.valorhora,0)) VALOR_HORA,
       u.tipo_profissional_id TIPO_PROFISSIONAL,
       nvl(tp.vigente, 'S') TP_VIGENTE
  from usuario            u,
       valor_hora_usuario vhu,
       tipoprofissional   tp
 where tp.id          (+) = u.tipo_profissional_id
   and vhu.usuario_id (+) = u.usuarioid;
--------------------------------------------------------------------------------
-- View v_custo_entidade  
create or replace view v_custo_entidade as
select mvcl.CUSTO_RECEITA_ID, mvcl.CUSTO_RECEITA_TIPO, mvcl.CUSTO_RECEITA_TITULO,
       mvcl.TIPO_ENTIDADE, mvcl.ENTIDADE_ID, mvcl.CUSTO_ENTIDADE_ID, 
       mvcl.DESP_TITULO, mvcl.SITUACAO, mvcl.CUSTO_ENTIDADE_ID || mvcl.SITUACAO ID_UNICO,
       sum(decode(mvcl.CONTABILIZAR_EM, 'CP', mvcl.VALOR, 0)) as CP,
       sum(decode(mvcl.CONTABILIZAR_EM, 'CR', mvcl.VALOR, 0)) as CR,
       sum(decode(mvcl.CONTABILIZAR_EM, 'RP', mvcl.VALOR, 0)) as RP,
       sum(decode(mvcl.CONTABILIZAR_EM, 'RR', mvcl.VALOR, 0)) as RR  
  from mv_custo_lancamento mvcl
group by mvcl.CUSTO_RECEITA_ID, mvcl.CUSTO_RECEITA_TIPO, mvcl.CUSTO_RECEITA_TITULO,
         mvcl.TIPO_ENTIDADE, mvcl.ENTIDADE_ID, mvcl.CUSTO_ENTIDADE_ID, 
         mvcl.DESP_TITULO, mvcl.SITUACAO; 
--------------------------------------------------------------------------------
-- View v_cronograma_hierarquia
create or replace view v_cronograma_hierarquia as
select 'A' TIPO_ENTIDADE, id ENTIDADE_ID, titulo TITULO, 
       tipoentidadepai TIPO_ENTIDADE_PAI , entidadepai ENTIDADE_ID_PAI, 
       projeto PROJETO_ID, datainicio INICIO_PREVISTO, prazoprevisto TERMINO_PREVISTO,
       horasprevistas HORAS_PREVISTAS, situacao SITUACAO
  from atividade
union all
select 'P' TIPO_ENTIDADE, id ENTIDADE_ID, titulo TITULO, null, null,
       id PROJETO_ID, datainicio INICIO_PREVISTO, prazoprevisto TERMINO_PREVISTO,
       horasprevistas HORAS_PREVISTAS, situacao SITUACAO
  from projeto
union all  
select 'T' TIPO_ENTIDADE, id ENTIDADE_ID, titulo TITULO, 
       decode(projeto, null, null, 'A') TIPO_ENTIDADE_PAI , atividade ENTIDADE_ID_PAI, 
       projeto PROJETO_ID , datainicio INICIO_PREVISTO, prazoprevisto TERMINO_PREVISTO,
       horasprevistas HORAS_PREVISTAS, situacao SITUACAO
  from tarefa; 
--------------------------------------------------------------------------------
-- v_entidade_dependentes
create or replace view v_entidade_dependentes as
select level nivel, 
       tipo_entidade TIPO_ENTIDADE, entidade_id ENTIDADE_ID, 
       connect_by_root(tipo_entidade) TIPO_ENTIDADE_DEP, connect_by_root(entidade_id) ENTIDADE_ID_DEP, 
       projeto_id PROJETO_ID, titulo TITULO, horas_previstas
  from v_cronograma_hierarquia
connect by prior entidade_id_pai   = entidade_id
       and prior tipo_entidade_pai = tipo_entidade; 
--------------------------------------------------------------------------------
-- View v_eva_calculo_diverso
create or replace view v_eva_calculo_diverso as
select evp.tipo_entidade, evp.entidade_id, evp.data,
       sum(case when evp.data >= mvcl.data and mvcl.contabilizar_em = 'CP' then nvl(mvcl.valor,0) else 0 end) PV,
       sum(case when evp.data >= mvcl.data and mvcl.contabilizar_em = 'CR' then nvl(mvcl.valor,0) else 0 end) AC,
       sum(case when mvcl.contabilizar_em = 'CP' then nvl(mvcl.valor,0) else 0 end) BAC,
       sum(case when trunc(add_months(evp.data,12),'Y')-1 >= mvcl.data and mvcl.contabilizar_em = 'CP' then nvl(mvcl.valor,0) else 0 end) PV_ANO,
       'D' TIPO
  from mv_custo_lancamento    mvcl,
       eva_ipg                evp,
       v_entidade_dependentes ved
 where mvcl.situacao         = 'V'
   and mvcl.tipo_entidade    = ved.tipo_entidade_dep
   and mvcl.entidade_id      = ved.entidade_id_dep
   and ved.entidade_id       = evp.entidade_id
   and ved.tipo_entidade     = evp.tipo_entidade
   and evp.tipo              = 'O'
group by evp.tipo_entidade, evp.entidade_id, evp.data;
/
   
--------------------------------------------------------------------------------
-- INDEXES ON MATERIALIZED VIEWS
--------------------------------------------------------------------------------
define CS_TBL_IND = &TABLESPACE_INDICES;

-- Índices para mv_custo_lancamento 
create index idx_mv_custo_lancamento_01 
       on mv_custo_lancamento(entidade_id, tipo_entidade) tablespace &CS_TBL_IND;
create index idx_mv_custo_lancamento_02 
       on mv_custo_lancamento(situacao) tablespace &CS_TBL_IND;
create index idx_mv_custo_lancamento_03 
       on mv_custo_lancamento(custo_receita_id, custo_receita_tipo) tablespace &CS_TBL_IND;
create index idx_mv_custo_lancamento_04 
       on mv_custo_lancamento(contabilizar_em) tablespace &CS_TBL_IND;
-- Índices para mv_valor_hora_simplificada       
create index IDX_MV_VALOR_HORA_SIMPL_01 
       on mv_valor_hora_simplificada(usuario_id) tablespace &CS_TBL_IND;
create index IDX_MV_VALOR_HORA_SIMPL_02
       on mv_valor_hora_simplificada(data_inicio) tablespace &CS_TBL_IND; 
create index IDX_MV_VALOR_HORA_SIMPL_03
       on mv_valor_hora_simplificada(tipo_profissional) tablespace &CS_TBL_IND; 
    
create or replace type t_tipo_campos is object(
  sec         number(3),
  nome        varchar2(32),
  tipo        varchar2(10),
  tamanho     number(5),
  decimais    number(2),
  separador   varchar2(1),
  formato     varchar2(50),
  obrigatorio varchar2(1),
  opcoes      varchar2(200),
  descricao   varchar2(2000));
/
        
--------------------------------------------------------------------------------
-- RECOMPILA OBJETOS
--------------------------------------------------------------------------------
begin
   pck_processo.precompila;
   commit;
end;
/
