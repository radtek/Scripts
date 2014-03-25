/******************************************************************************\
* Roteiro para migra��o � vers�o de calend�rio (6.0.0.0)                       *
* Parte III - Migra��o de dados de estruturas anteriores para estruturas v6.0  *
* Autor: Charles Falc�o                     Data de Publica��o:   /   /2009    *
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

-- Migra��o de conhecimentos profissionais para nova tabela
prompt ...migra conhecimento profissional...
insert into conhecimento_profissional (id, id_pai, titulo, descricao, vigente,
                                       nivel_default, tipo)
select conhecimentoid, null, titulo, descricao, decode(vigente, 'S', 'Y', 'N'), 
       null, 'C'
  from conhecimentoprofissional;
commit;
/
  
-- Gera��o de novos IDs para conhecimento_usuario
prompt ...cria IDs para conhecimento usu�rio...
update conhecimento_usuario
   set id = conhecimento_usuario_seq.nextval;
commit;
/
   
-- Gera registros de avalia��es para conhecimentos existentes
prompt ...migra conhecimento de usu�rio...
insert into conhec_usuario_aval (id, conhecimento_id, usuario_id, usuario_avaliador_id,
                                 data_avaliacao, usuario_aprovador_id, data_aprovacao,
                                 projeto_id, situacao, motivo, justificativa, nivel_id)
       select conhec_usuario_aval_seq.nextval, cu.conhecimento_id, cu.usuario_id, 
              tc.valor_varchar, sysdate, tc.valor_varchar, sysdate, null, 'A', 
              'Migra��o de Vers�o do TraceGP',
              'Avalia��o inclu�da automaticamente para manter compatibilidade com vers�es anteriores',
              cu.nivel_id              
         from conhecimento_usuario cu,
              tracegp_config tc
        where tc.variavel = 'GERAL: USR_ADM_TRACE';
commit;
/
        
-- Atualiza conhecimento e gera avalia��es para as avalia��es existentes
prompt ...migra avaliacoes de conhecimentos existentes...
declare 
  ln_id number(10);
begin
  for aval_conhec in (select * from avaliacaoconhecimento order by avaliacaoid) loop
    -- Verifica se j� existe registro na conhecimento_usuario
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
      -- Se j� possui o conhecimento atualiza com o novo n�vel
      update conhecimento_usuario
         set nivel_id = aval_conhec.nivelid
       where id       = ln_id;
    else
      -- Se n�o possui o conhecimento adiciona o conhecimento
      select conhecimento_usuario_seq.nextval into ln_id from dual;
      insert into conhecimento_usuario (id, usuario_id, conhecimento_id, nivel_id)
             values (ln_id, aval_conhec.usuarioid, aval_conhec.conhecimentoid,
                     aval_conhec.nivelid);
    end if;
    
    -- Inclui na nova tabela de avalia��o de conhecimento
    insert into conhec_usuario_aval (id, conhecimento_id, usuario_id, usuario_avaliador_id,
                                     data_avaliacao, usuario_aprovador_id, data_aprovacao,
                                     projeto_id, situacao, motivo, justificativa, nivel_id)
           select conhec_usuario_aval_seq.nextval, aval_conhec.conhecimentoid,
                  aval_conhec.usuarioid, aval_conhec.avaliador, aval_conhec.dataavaliacao,
                  valor_varchar, sysdate, null, 'A', 'Migra��o de Vers�o do TraceGP',
                  'Avalia��o migrada automaticamente de vers�es anteriores',
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
  -- Monta t�tulo do calend�rio padr�o
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
    lv_titulo := 'Padr�o 8h';
  end if;
  
  -- Cria calend�rio padr�o
  select calendario_seq.nextval into ln_calendario_id from dual;
  
  insert into calendario (id, titulo, vigente, carga_horaria, tipo)
         values (ln_calendario_id, lv_titulo, 'Y', 480, 'B');
  commit;
  
  -- Monta demais calend�rios (conforme padr�es hor�rios ativos)
  for phor in (select id, tempotrabalho, nome from padraohorario 
                where corrente = 'S' and vigente = 'S') loop
    -- Nome do calend�rio
    if (phor.nome = 'bd.padraohorario.padraohorario1') then
      if lv_idioma = 'es_ES' then
        lv_titulo := '';
      elsif lv_idioma = 'en_US' then
        lv_titulo := '';
      elsif lv_idioma = 'de_DE' then
        lv_titulo := '';
      else
        lv_titulo := 'Padr�o';
      end if;
    else 
      lv_titulo := phor.nome;
    end if;
    
    -- Cria calend�rio e mant� apontador do padr�o hor�rio
    select calendario_seq.nextval into ln_cal_id from dual;
    
    lt_phor(phor.id) := ln_cal_id;
    
    insert into calendario (id, titulo, vigente, carga_horaria, tipo, pai_id)
           values (ln_cal_id, lv_titulo, 'Y', phor.tempotrabalho, 'B', ln_calendario_id );
    commit;
    
  end loop;
  
  -- Atualiza tabela usu�rio
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
                            
  -- Para demais utiliza o padr�o 8h
  update usuario
     set calendario_base_id = ln_calendario_id
   where calendario_base_id is null;
   
  -- Atualiza calend�rio de projetos
  update projeto
     set calendario_base_id = ln_calendario_id
   where calendario_base_id is null;
  
  -- Cria calend�rios de projetos
  insert into calendario (id, titulo, vigente, carga_horaria, tipo, projeto_id)
         select calendario_seq.nextval, 
                'Calend�rio do Projeto ' || id || ' - ' || titulo, 
                'Y', 480, 'P', id
           from projeto p
          where not exists (select 1 
                              from calendario c 
                             where c.tipo = 'P' and c.projeto_id = p.id);
  commit;
end;
/

-- Aloca��es j� existentes
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
