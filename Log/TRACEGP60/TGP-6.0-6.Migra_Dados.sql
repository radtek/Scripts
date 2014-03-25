/******************************************************************************\
* Roteiro para migração à versão de calendário (6.0.0.0)                       *
* Parte III - Migração de dados de estruturas anteriores para estruturas v6.0  *
* Autor: Charles Falcão                     Data de Publicação:   /   /2009    *
\******************************************************************************/

--------------------------------------------------------------------------------
--
-- Define nome dos tablespaces.
--
--------------------------------------------------------------------------------
alter package pck_processo compile;

begin
  pck_processo.pRecompila;
  commit;
end;
/

prompt ...ajusta data de atualizacao de estados no formulario...
update formulario
   set data_atualizacao_estados = sysdate
 where formulario_id in (select formulario_id from estado_formulario);
commit;
/

-- Migração de conhecimentos profissionais para nova tabela
prompt ...migra conhecimento profissional...
insert into conhecimento_profissional (id, id_pai, titulo, descricao, vigente,
                                       nivel_default, tipo)
select conhecimentoid, null, titulo, descricao, decode(vigente, 'S', 'Y', 'N'), 
       null, 'C'
  from conhecimentoprofissional;
commit;
/
  
-- Geração de novos IDs para conhecimento_usuario
prompt ...cria IDs para conhecimento usuário...
update conhecimento_usuario
   set id = conhecimento_usuario_seq.nextval;
commit;
/
   
-- Gera registros de avaliações para conhecimentos existentes
prompt ...migra conhecimento de usuário...
insert into conhec_usuario_aval (id, conhecimento_id, usuario_id, usuario_avaliador_id,
                                 data_avaliacao, usuario_aprovador_id, data_aprovacao,
                                 projeto_id, situacao, motivo, justificativa, nivel_id)
       select conhec_usuario_aval_seq.nextval, cu.conhecimento_id, cu.usuario_id, 
              tc.valor_varchar, sysdate, tc.valor_varchar, sysdate, null, 'A', 
              'Migração de Versão do TraceGP',
              'Avaliação incluída automaticamente para manter compatibilidade com versões anteriores',
              cu.nivel_id              
         from conhecimento_usuario cu,
              tracegp_config tc
        where tc.variavel = 'GERAL: USR_ADM_TRACE';
commit;
/
        
-- Atualiza conhecimento e gera avaliações para as avaliações existentes
prompt ...migra avaliacoes de conhecimentos existentes...
declare 
  ln_id number(10);
begin
  for aval_conhec in (select * from avaliacaoconhecimento order by avaliacaoid) loop
    -- Verifica se já existe registro na conhecimento_usuario
    begin
      select id
        into ln_id
        from conhecimento_usuario
       where conhecimento_id = aval_conhec.conhecimentoid
         and usuario_id      = aval_conhec.usuarioid;
    exception
      when NO_DATA_FOUND then
        ln_id := 0;
    end;
       
    if ln_id > 0 then
      -- Se já possui o conhecimento atualiza com o novo nível
      update conhecimento_usuario
         set nivel_id = aval_conhec.nivelid
       where id       = ln_id;
    else
      -- Se não possui o conhecimento adiciona o conhecimento
      select conhecimento_usuario_seq.nextval into ln_id from dual;
      insert into conhecimento_usuario (id, usuario_id, conhecimento_id, nivel_id)
             values (ln_id, aval_conhec.usuarioid, aval_conhec.conhecimentoid,
                     aval_conhec.nivelid);
    end if;
    
    -- Inclui na nova tabela de avaliação de conhecimento
    insert into conhec_usuario_aval (id, conhecimento_id, usuario_id, usuario_avaliador_id,
                                     data_avaliacao, usuario_aprovador_id, data_aprovacao,
                                     projeto_id, situacao, motivo, justificativa, nivel_id)
           select conhec_usuario_aval_seq.nextval, aval_conhec.conhecimentoid,
                  aval_conhec.usuarioid, aval_conhec.avaliador, aval_conhec.dataavaliacao,
                  valor_varchar, sysdate, null, 'A', 'Migração de Versão do TraceGP',
                  'Avaliação migrada automaticamente de versões anteriores',
                  aval_conhec.nivelid
             from tracegp_config
            where variavel = 'GERAL: USR_ADM_TRACE';
  end loop;
  commit;
end;
/

-- Copia responsavel para gerente de recurso
prompt ...cria a figura do gerente de recursos...
update usuario set gerente_recurso = responsavel_id where gerente_recurso is null;
commit;
/

-- Criacao de calendarios
prompt ...cria calendarios...
declare
  type t_phor is table of calendario.id%type index by binary_integer;
  
  lv_idioma        configuracoes.idioma_padrao%type;
  lv_titulo        calendario.titulo%type;
  ln_calendario_id calendario.id%type;
  ln_cal_id        calendario.id%type;
  lt_phor          t_phor;
  
begin
  -- Monta título do calendário padrão
  begin
    select idioma_padrao
      into lv_idioma
      from configuracoes
     where id = (select max(id) from configuracoes);
  exception
    when OTHERS then
      lv_idioma := 'pt_BR';
  end;
    
  if lv_idioma = 'es_ES' then
    lv_titulo := '';
  elsif lv_idioma = 'en_US' then
    lv_titulo := '';
  elsif lv_idioma = 'de_DE' then
    lv_titulo := '';
  else
    lv_titulo := 'Padrão 8h';
  end if;
  
  -- Cria calendário padrão
  select calendario_seq.nextval into ln_calendario_id from dual;
  
  insert into calendario (id, titulo, vigente, carga_horaria, tipo)
         values (ln_calendario_id, lv_titulo, 'Y', 480, 'B');
  commit;
  
  -- Monta demais calendários (conforme padrões horários ativos)
  for phor in (select id, tempotrabalho, nome from padraohorario 
                where corrente = 'S' and vigente = 'S') loop
    -- Nome do calendário
    if (phor.nome = 'bd.padraohorario.padraohorario1') then
      if lv_idioma = 'es_ES' then
        lv_titulo := '';
      elsif lv_idioma = 'en_US' then
        lv_titulo := '';
      elsif lv_idioma = 'de_DE' then
        lv_titulo := '';
      else
        lv_titulo := 'Padrão';
      end if;
    else 
      lv_titulo := phor.nome;
    end if;
    
    -- Cria calendário e manté apontador do padrão horário
    select calendario_seq.nextval into ln_cal_id from dual;
    
    lt_phor(phor.id) := ln_cal_id;
    
    insert into calendario (id, titulo, vigente, carga_horaria, tipo, pai_id)
           values (ln_cal_id, lv_titulo, 'Y', phor.tempotrabalho, 'B', ln_calendario_id );
    commit;
    
  end loop;
  
  -- Atualiza tabela usuário
  for usr in (select usuarioid, padraohorario
               from usuario
              where calendario_base_id is null
                and padraohorario in (select id
                                        from padraohorario 
                                       where corrente = 'S' and vigente = 'S')) loop
    
    ln_cal_id := lt_phor(usr.padraohorario);
    
    update usuario
       set calendario_base_id = ln_cal_id
     where usuarioid = usr.usuarioid;
       
  end loop;
                            
  -- Para demais utiliza o padrão 8h
  update usuario
     set calendario_base_id = ln_calendario_id
   where calendario_base_id is null;
   
  -- Atualiza calendário de projetos
  update projeto
     set calendario_base_id = ln_calendario_id
   where calendario_base_id is null;
  
  -- Cria calendários de projetos
  insert into calendario (id, titulo, vigente, carga_horaria, tipo, projeto_id)
         select calendario_seq.nextval, 
                'Calendário do Projeto ' || id || ' - ' || titulo, 
                'Y', 480, 'P', id
           from projeto p
          where not exists (select 1 
                              from calendario c 
                             where c.tipo = 'P' and c.projeto_id = p.id);
  commit;
end;
/

-- Alocações já existentes
prompt ...atualiza informacoes de alocacoes em projetos...
update projeto
   set alocar_automaticamente = 'Y',
       regra_alocacao         = 2
 where regra_alocacao is null;
 
update tarefa
   set alocar_automaticamente = 'Y',
       regra_alocacao         = 2
 where regra_alocacao is null;
commit;
/
       
prompt ...migra alocacoes existentes...
insert into hora_alocada(id, tarefa_id, data, minutos)
select hora_alocada_seq.nextval, tid, dt, mi
  from ( select tarefaid tid, trunc(data) dt, sum(horas) mi
           from alocacao
         group by tarefaid, trunc(data) );
update tarefa
   set alocar_automaticamente = 'Y',
       regra_alocacao         = 1
 where id in (select tarefaid from alocacao);
commit;
/
        

prompt ...migracao de dados concluida.
