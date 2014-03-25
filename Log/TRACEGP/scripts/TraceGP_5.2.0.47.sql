/*****************************************************************************\ 
 * TraceGP 5.2.0.47                                                         *
\*****************************************************************************/

create or replace package pck_proximo_estado is

   type t_rec_proximo_estado is record (
      row_id        rowid,
      formulario_id number(10));

   type tt_array_proximo_estado is table of t_rec_proximo_estado index by binary_integer;

   gt_registros_alterados tt_array_proximo_estado;
   gt_array_vazio        tt_array_proximo_estado;

end;
/
create or replace package body pck_proximo_estado is

end;
/

CREATE OR REPLACE PACKAGE "PCK_ESTADO_FORMULARIO" is

   type t_rec_estado_formulario is record (
      row_id         rowid,
      formulario_id  number,
      estado_id      number,
      sla_default_id number);

   type tt_array_estado_formulario is table of t_rec_estado_formulario index by binary_integer;

   gt_registros_alterados tt_array_estado_formulario;
   gt_array_vazio        tt_array_estado_formulario;

end;
/

CREATE OR REPLACE PACKAGE BODY "PCK_ESTADO_FORMULARIO" is

end;
/

CREATE OR REPLACE TRIGGER "TRG_ESTADO_FORMULARIO_IUD_AR" 
AFTER DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario
FOR EACH ROW
DECLARE

BEGIN
   if (inserting) then
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count + 1).row_id  := :new.rowid;
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count).formulario_id  := :old.formulario_id;
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count).estado_id  := :old.estado_id;
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count).sla_default_id  := :old.sla_default_id;
   elsif (updating) or (deleting) then
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count + 1).row_id  := :old.rowid;
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count).formulario_id  := :old.formulario_id;
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count).estado_id  := :old.estado_id;
        pck_estado_formulario.gt_registros_alterados(pck_estado_formulario.gt_registros_alterados.count).sla_default_id  := :old.sla_default_id;
   end if;

END trg_estado_formulario_iud_ar;
/

CREATE OR REPLACE TRIGGER TRG_ESTADO_FORMULARIO_IUD_AS
AFTER DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario
DECLARE
ln_formulario_id estado_formulario.formulario_id%type;
ln_estado_id estado_formulario.estado_id%type;
ln_sla_id estado_formulario.sla_default_id%type;
ln_ret number;
BEGIN
for i in 1 .. pck_estado_formulario.gt_registros_alterados.count loop
  ln_formulario_id := pck_estado_formulario.gt_registros_alterados(i).formulario_id;
  ln_estado_id     := pck_estado_formulario.gt_registros_alterados(i).estado_id;
  ln_sla_id        := pck_estado_formulario.gt_registros_alterados(i).sla_default_id;

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

CREATE OR REPLACE TRIGGER trg_proximo_estado_iud_ar
AFTER DELETE OR INSERT OR UPDATE
      ON proximo_estado
FOR EACH ROW
DECLARE
begin
   if (inserting) then
        pck_proximo_estado.gt_registros_alterados(pck_proximo_estado.gt_registros_alterados.count + 1).row_id  := :new.rowid;
        pck_proximo_estado.gt_registros_alterados(pck_proximo_estado.gt_registros_alterados.count).formulario_id  := :new.formulario_id;
   elsif (updating) or (deleting) then
        pck_proximo_estado.gt_registros_alterados(pck_proximo_estado.gt_registros_alterados.count + 1).row_id  := :old.rowid;
        pck_proximo_estado.gt_registros_alterados(pck_proximo_estado.gt_registros_alterados.count).formulario_id  := :old.formulario_id;
   end if;

END trg_proximo_estado_iud_ar;
/

CREATE OR REPLACE TRIGGER trg_proximo_estado_iud_as
AFTER DELETE OR INSERT OR UPDATE
      ON proximo_estado
DECLARE
ln_formulario_id proximo_estado.formulario_id%type;
ln_ret number;
BEGIN
for i in 1 .. pck_proximo_estado.gt_registros_alterados.count loop
  ln_formulario_id := pck_proximo_estado.gt_registros_alterados(i).formulario_id;
   for c in (select d.demanda_id
        from demanda d
        where (d.formulario_id = ln_formulario_id or ln_formulario_id is null)
        and (d.formulario_id, d.situacao) not in (select formulario_id, estado_id from estado_formulario where estado_final = 'S')
        for update) loop

      update sla_ativo_demanda a
      set qtd_minutos_critico = pck_sla.f_restante_critico(c.demanda_id)
      where demanda_id = c.demanda_id
      and   sla_tendencia_id is not null;

   end loop;

end loop;
END trg_proximo_estado_iud_as;
/

delete from sla_nivel
 where rowid in (select max(rowid)
                   from sla_nivel
                  where (sla_id, estado_sla_id) in (select sla_id, estado_sla_id
                                                      from sla_nivel
                                                     group by sla_id, estado_sla_id
                                                    having count(1) > 1)
                  group by sla_id, estado_sla_id);
commit;
/
                  
alter table sla_nivel add constraint UK_SLA_NIVEL_01
  unique (sla_id, estado_sla_id);
  

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '47', 2, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                    
select * from v_versao;
/

  
  
