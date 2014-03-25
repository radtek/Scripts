create or replace trigger trg_regra_calendario_iu_br
  before insert or update on regra_calendario
  for each row
begin    
  -- Para regras do tipo Carga Horária torna período amplo
  if :new.frequencia = 'C' then
     :new.vigencia_inicial := to_date('01012000', 'ddmmyyyy');
     :new.vigencia_final   := to_date('31122100', 'ddmmyyyy');
  end if;
  
  -- Somente calendário de recurso pode possuir regra do tipo C
  if :new.frequencia = 'C' and (:new.projeto_id is null or :new.usuario_id is null) then
    raise_application_error(-20001, 'Somente calendário de recurso pode possuir regra de carga horária'); 
  end if;
  
  -- 
  if :new.calendario_id is null and :new.usuario_id is null and :new.projeto_id is null then
      raise_application_error(-20002, 'Uma regra deve estar associada a um calendário base'
                              || ', de projeto, de usuário ou de recurso'); 
  end if;
  
  if :new.calendario_id is not null and :new.usuario_id is not null then
      raise_application_error(-20003, 'Uma regra não pode estar associada simultaneamente'
                              || ' a um calendário base e de usuário');      
  end if;
  
end;
/

create or replace trigger trg_hora_alocada_iu_br
  before insert or update on hora_alocada
  for each row
begin    
  :new.data := trunc(:new.data);
end;
/

create or replace trigger TRG_ESTADO_FORM_SINCDES_IUD_AR
  after insert or update or delete 
  of estado_final, retorna_estado_anterior, vigente
  on estado_formulario
  for each row
begin
  if INSERTING or UPDATING then
    update formulario
       set data_atualizacao_estados = sysdate
     where formulario_id = :new.formulario_id;
  else
    update formulario
       set data_atualizacao_estados = sysdate
     where formulario_id = :old.formulario_id;
  end if;
end TRG_ESTADO_FORM_SINCDES_IUD_AR;
/

create or replace trigger TRG_PROX_ESTADO_SINCDES_IUD_AR
  after insert or update or delete 
  of estado_destino
  on proximo_estado
  for each row
begin
  if INSERTING or UPDATING then
    update formulario
       set data_atualizacao_estados = sysdate
     where formulario_id = :new.formulario_id;
  else
    update formulario
       set data_atualizacao_estados = sysdate
     where formulario_id = :old.formulario_id;
  end if;
end TRG_PROX_ESTADO_SINCDES_IUD_AR;
/

create or replace trigger TRG_TRAN_ESTADO_SINCDES_IUD_AR
  after insert or update or delete 
  of estado_id, botao_acao_termo_id
  on transicao_estado
  for each row
begin
  if INSERTING or UPDATING then
    update formulario
       set data_atualizacao_estados = sysdate
     where formulario_id = :new.formulario_id;
  else
    update formulario
       set data_atualizacao_estados = sysdate
     where formulario_id = :old.formulario_id;
  end if;
end TRG_TRAN_ESTADO_SINCDES_IUD_AR;
/

create or replace trigger TRG_FORMULARIO_SINCDES_IU_BR
  before insert or update 
  of estado_inicial
  on formulario
  for each row
begin
  :new.data_atualizacao_estados := sysdate;
end TRG_FORMULARIO_SINCDES_IU_BR;
/

create or replace trigger TRG_FORM_FLUXO_DESENHO_IU_BR
  before insert or update
  on formulario_fluxo_desenho
  for each row
begin
  :new.data := sysdate;
end TRG_FORM_FLUXO_DESENHO_IU_BR;
/

------------------------------------
/******************************************************************************\
* TRIGGERS para a tabela estado_formulario                                     *
\******************************************************************************/

--> Triggers no arquivo:
--       trg_estado_formulario_iud_bs
--       trg_estado_formulario_iud_ar
--       trg_estado_formulario_iud_as

--------------------------------------------------------------------------------
create or replace
TRIGGER trg_estado_formulario_iud_bs
BEFORE DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario
DECLARE

BEGIN
   pck_estado_formulario.gt_registros_alterados := pck_estado_formulario.gt_array_vazio;

END trg_estado_formulario_iud_bs;
/
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_estado_formulario_iud_ar
AFTER DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario
FOR EACH ROW	  
DECLARE
ln_ind number;
BEGIN
   ln_ind := pck_estado_formulario.gt_registros_alterados.count + 1;
   if (inserting) then
        pck_estado_formulario.gt_registros_alterados(ln_ind).row_id  := :new.rowid;
        pck_estado_formulario.gt_registros_alterados(ln_ind).formulario_id  := :new.formulario_id;
        pck_estado_formulario.gt_registros_alterados(ln_ind).estado_id  := :new.estado_id;
   elsif (updating) or (deleting) then
        pck_estado_formulario.gt_registros_alterados(ln_ind).row_id  := :old.rowid;
        pck_estado_formulario.gt_registros_alterados(ln_ind).formulario_id  := :old.formulario_id;
        pck_estado_formulario.gt_registros_alterados(ln_ind).estado_id  := :old.estado_id;
   end if;

END trg_estado_formulario_iud_ar;
/
--------------------------------------------------------------------------------
create or replace
TRIGGER trg_estado_formulario_iud_as
AFTER DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario 
DECLARE
ln_formulario_id estado_formulario.formulario_id%type;
ln_estado_id estado_formulario.estado_id%type;
ln_sla_id estado_formulario.sla%type;
ln_ret number;
BEGIN
for i in 1 .. pck_estado_formulario.gt_registros_alterados.count loop 

   begin
      select formulario_id, estado_id, sla_default_id
      into ln_formulario_id, ln_estado_id,ln_sla_id
      from estado_formulario
      where rowid = pck_estado_formulario.gt_registros_alterados(i).row_id;
   exception
   when others then
      ln_formulario_id := pck_estado_formulario.gt_registros_alterados(i).formulario_id;
      ln_estado_id := pck_estado_formulario.gt_registros_alterados(i).estado_id;
   end;

   if ln_formulario_id > 0 then
     for c in (select d.demanda_id
          from demanda d
          where d.formulario_id = ln_formulario_id
          and   d.situacao = ln_estado_id
          for update) loop
  
        update sla_ativo_demanda
        set sla_estado_id = ln_sla_id,
            qtd_minutos_critico = pck_sla.f_restante_critico(c.demanda_id)
        where demanda_id = c.demanda_id;
  
        pck_condicional.p_ExecutarRegrasCondicionais (c.demanda_id, 'auto', ln_ret);
  
     end loop;
   else
     for c in (select d.demanda_id
          from demanda d
          where (formulario_id, situacao) not in (select formulario_id, estado_id from estado_formulario where estado_final = 'S')
          for update) loop
  
        update sla_ativo_demanda
        set sla_estado_id = ln_sla_id,
            qtd_minutos_critico = pck_sla.f_restante_critico(c.demanda_id)
        where demanda_id = c.demanda_id;
  
        pck_condicional.p_ExecutarRegrasCondicionais (c.demanda_id, 'auto', ln_ret);
  
     end loop;
   end if;
   

end loop; 
END trg_estado_formulario_iud_as;
/
/******************************************************************************\
* TRIGGERS para a tabela mapa_objetivo                                        *
\******************************************************************************/

--> Triggers no arquivo:
--       trg_mapa_objetivo_d_as

--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_mapa_objetivo_d_as
BEFORE DELETE
      ON mapa_objetivo
FOR EACH ROW
DECLARE
ls_tipo varchar2(1):='O';
BEGIN

delete from mapa_relacao
   where origem_id = :old.id and
         tipo_origem = ls_tipo;

delete from mapa_relacao
   where destino_id = :old.id and
         tipo_destino = ls_tipo;

END trg_mapa_objetivo_d_as;
/
/******************************************************************************\
* TRIGGERS para a tabela mapa_perspectiva                                     *
\******************************************************************************/

--> Triggers no arquivo:
--       trg_mapa_perspectiva_d_as

--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_mapa_perspectiva_d_as
BEFORE DELETE
      ON mapa_perspectiva
FOR EACH ROW
DECLARE
ls_tipo varchar2(1):='P';
BEGIN

delete from mapa_relacao
   where origem_id = :old.id and
         tipo_origem = ls_tipo;

delete from mapa_relacao
   where destino_id = :old.id and
         tipo_destino = ls_tipo;

END trg_mapa_perspectiva_d_as;
/
/******************************************************************************\
* TRIGGERS para a tabela mapa_estrategico                                     *
\******************************************************************************/

--> Triggers no arquivo:
--       trg_mapa_estrategico_d_as

--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_mapa_estrategico_d_as
BEFORE DELETE
      ON mapa_estrategico
FOR EACH ROW
DECLARE
ls_tipo varchar2(1):='M';
BEGIN

delete from mapa_relacao
   where origem_id = :old.id and
         tipo_origem = ls_tipo;

delete from mapa_relacao
   where destino_id = :old.id and
         tipo_destino = ls_tipo;

END trg_mapa_estrategico_d_as;
/
/******************************************************************************\
* TRIGGERS para a tabela mapa_indicador                                     *
\******************************************************************************/

--> Triggers no arquivo:
--       trg_mapa_indicador_d_as

--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_mapa_indicador_d_as
BEFORE DELETE
      ON mapa_indicador
FOR EACH ROW
DECLARE
ln_qtde number:=0;
BEGIN

-- Nao excluir se tiver indicador com apuração processada
select count(*) into ln_qtde from mapa_indicador_apuracao ma
where ma.indicador_id = :old.id and situacao='P';

if ln_qtde>0 then
	raise_application_error(-20001, 'O Indicador já possui apuração processada. Não pode ser excluído.');
	return;
end if;

delete from mapa_indicador_apuracao ma
where ma.indicador_id = :old.id;

END trg_mapa_indicador_d_as;
/
