create or replace package pck_migra is
  procedure p_perfil_permis(pn_perfil          in number, 
                            pn_tipo_lancamento in number,
                            pn_tipo_entidade   in varchar2,
                            pn_permissao       in varchar2);
  procedure p_perfil_fim;
  procedure p_papel_permis(pn_papel           in number, 
                           pn_tipo_lancamento in number,
                           pn_tipo_entidade   in varchar2,
                           pn_permissao       in varchar2);
  procedure p_papel_fim;
  procedure form_permis(pn_formulario      number,
                        pn_tipo_lancamento number,
                        pn_permissao       varchar2, 
                        pn_regra           number);
                        
end pck_migra;
/

create or replace package body pck_migra is
  -----------------------------------------------------------------------------
  procedure p_perfil_permis(pn_perfil          in number, 
                            pn_tipo_lancamento in number,
                            pn_tipo_entidade   in varchar2,
                            pn_permissao       in varchar2) is
    ln_conta number;
  begin
    select count(1)
      into ln_conta
      from tipo_lancamento_perfil
     where tipo_lancamento_id = pn_tipo_lancamento
       and perfilid           = pn_perfil
       and tipoentidade       = pn_tipo_entidade;
       
    if ln_conta = 0 then
      insert into tipo_lancamento_perfil(id, tipo_lancamento_id, perfilid,
                                         tipoentidade, inclusao, visualizacao, estorno)
      select tipo_lancamento_perfil_seq.nextval, pn_tipo_lancamento, pn_perfil, pn_tipo_entidade,
             decode(pn_permissao, 'I', 'Y', 'N'), decode(pn_permissao, 'V', 'Y', 'N'), 
             decode(pn_permissao, 'E', 'Y', 'N')
        from dual;
    else
      update tipo_lancamento_perfil
         set inclusao     = case when pn_permissao = 'I' then 'Y' else inclusao     end,
             visualizacao = case when pn_permissao = 'V' then 'Y' else visualizacao end,
             estorno      = case when pn_permissao = 'E' then 'Y' else estorno      end
       where tipo_lancamento_id = pn_tipo_lancamento
         and perfilid           = pn_perfil
         and tipoentidade       = pn_tipo_entidade;                 
    end if; 
  end p_perfil_permis;                     
  -----------------------------------------------------------------------------
  procedure p_perfil_fim is    
  begin
    -- Remove permissões de estorno onde não há permissão de planejamento ou realização
    delete from tipo_lancamento_perfil 
     where estorno      = 'Y'
       and inclusao     = 'N';       
  end p_perfil_fim;
  -----------------------------------------------------------------------------
  procedure p_papel_permis(pn_papel           in number, 
                           pn_tipo_lancamento in number,
                           pn_tipo_entidade   in varchar2,
                           pn_permissao       in varchar2) is
    ln_conta number;
  begin
    select count(1)
      into ln_conta
      from tipo_lancamento_papel
     where tipo_lancamento_id = pn_tipo_lancamento
       and papel_id           = pn_papel
       and tipoentidade       = pn_tipo_entidade;
       
    if ln_conta = 0 then
      insert into tipo_lancamento_papel(id, tipo_lancamento_id, papel_id,
                                         tipoentidade, inclusao, visualizacao, estorno)
      select tipo_lancamento_papel_seq.nextval, pn_tipo_lancamento, pn_papel, pn_tipo_entidade,
             decode(pn_permissao, 'I', 'Y', 'N'), decode(pn_permissao, 'V', 'Y', 'N'), 
             decode(pn_permissao, 'E', 'Y', 'N')
        from dual;
    else
      -- 
      if pn_permissao = 'I' then
        update tipo_lancamento_papel set inclusao = 'Y' 
         where tipo_lancamento_id = pn_tipo_lancamento
           and papel_id           = pn_papel
           and tipoentidade       = pn_tipo_entidade;
      elsif pn_permissao = 'V' then
        update tipo_lancamento_papel set visualizacao = 'Y' 
         where tipo_lancamento_id = pn_tipo_lancamento
           and papel_id           = pn_papel
           and tipoentidade       = pn_tipo_entidade;
      elsif pn_permissao = 'E' then
        update tipo_lancamento_papel set estorno = 'Y' 
         where tipo_lancamento_id = pn_tipo_lancamento
           and papel_id           = pn_papel
           and tipoentidade       = pn_tipo_entidade;    
     end if;                
    end if; 
  end p_papel_permis;                     
  -----------------------------------------------------------------------------
  procedure p_papel_fim is    
  begin
    -- Remove permissões de estorno onde não há permissão de planejamento ou realização
    delete from tipo_lancamento_papel
     where estorno      = 'Y'
       and inclusao     = 'N';       
  end p_papel_fim;  
  -----------------------------------------------------------------------------
  procedure form_permis(pn_formulario      number,
                        pn_tipo_lancamento number,
                        pn_permissao       varchar2, 
                        pn_regra           number) is
    ln_id    number(10);
    ln_regra number(10);
  begin
    -- Verifica se regra é valida
    if pn_regra <> 0 then
      ln_regra := pn_regra;
    else
      begin
        select regra_id
          into ln_regra
          from regra_formulario
         where formulario_id = pn_formulario
           and titulo        = '.SEM.ACESSO.';
      exception
        when NO_DATA_FOUND then
          select max(nvl(regra_id,0)) + 1 
            into ln_regra 
            from regra_formulario
           where formulario_id = pn_formulario;
          
          insert into regra_formulario (formulario_id, regra_id, titulo, sistema, vigente)
                 values (pn_formulario, ln_regra, '.SEM.ACESSO.', 'N', 'S');       
      end;
    end if;
    -- Busca tipo_lanc_entidade para planejado/realizado
    begin
      select id
        into ln_id
        from tipo_lancamento_entidade
       where tipoentidade       = 'D'
         and identidade         = pn_formulario
         and tipo_lancamento_id = pn_tipo_lancamento;
    exception
      when NO_DATA_FOUND then
        select tipo_lancamento_entidade_seq.nextval into ln_id from dual;
        insert into tipo_lancamento_entidade (id, identidade, tipo_lancamento_id, 
                                              tipoentidade, visivel, ordem)
               values (ln_id, pn_formulario, pn_tipo_lancamento, 'D', 
                       'Y', pn_tipo_lancamento - 1);
    end;
    
    -- Inclui / atualiza regra_tipo_lanc_formulario
    begin
      insert into regra_tipo_lanc_formulario(id, tipo_lanc_entidade_id, regra_id, 
                                             formulario_id, tipo_permissao)
             values (regra_tipo_lanc_formulario_seq.nextval, ln_id, ln_regra,
                     pn_formulario, pn_permissao);
    exception
      when others then
        null;
    end; 
  end form_permis;
  -----------------------------------------------------------------------------                      
  
end pck_migra;
/


--
-- Realiza Migração
--

begin
  -- Migra permissões de custos em perfis
  for perf in (select pip.perfil_id, pip.tipo_acesso, 
                      pi.permissao_item_id, pi.codigo
                 from permissao_item pi,
                      permissao_item_perfil pip
                where pip.permissao_item_id = pi.permissao_item_id
                  and pi.codigo like '%CUSTO%') loop
    -- projeto
    if (perf.codigo = 'I_PROJETO_PLANEJAR_CUSTOS_RECEITAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'P', 'I');
    elsif (perf.codigo = 'I_PROJETO_REALIZAR_CUSTOS_RECEITAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'P', 'I');
    elsif (perf.codigo = 'I_PROJETO_VISUALIZAR_CUSTOS_RECEITAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'P', 'V');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'P', 'V');
    elsif (perf.codigo = 'I_PROJETO_ESTORNAR_CUSTOS_RECEITAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'P', 'E');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'P', 'E');
    -- atividade
    elsif (perf.codigo = 'I_ATIVIDADE_PLANEJAR_CUSTOS_RECEITAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'A', 'I');
    elsif (perf.codigo = 'I_ATIVIDADE_REALIZAR_CUSTOS_RECEITAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'A', 'I');
    elsif (perf.codigo = 'I_ATIVIDADE_VISUALIZAR_CUSTOS_RECEITAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'A', 'V');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'A', 'V');
    elsif (perf.codigo = 'I_ATIVIDADE_ESTORNAR_CUSTOS_RECEITAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'A', 'E');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'A', 'E');
    -- tarefa de projeto
    elsif (perf.codigo = 'I_TAR_PROJ_PLANEJAR_CUSTOS_RECEITAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'T', 'I');
    elsif (perf.codigo = 'I_TAR_PROJ_REALIZAR_CUSTOS_RECEITAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'T', 'I');
    elsif (perf.codigo = 'I_TAR_PROJ_VISUALIZAR_CUSTOS_RECEITAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'T', 'V');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'T', 'V');
    elsif (perf.codigo = 'I_TAR_PROJ_ESTORNAR_CUSTOS_RECEITAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'T', 'E');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'T', 'E');
    -- tarefa de projeto
    elsif (perf.codigo = 'I_TAR_AV_PLANEJAR_CUSTOS_RECEITAS_PROPRIAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'V', 'I');
    elsif (perf.codigo = 'I_TAR_AV_REALIZAR_CUSTOS_RECEITAS_PROPRIAS') then      
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'V', 'I');
    elsif (perf.codigo = 'I_TAR_AV_VISUALIZAR_CUSTOS_RECEITAS_PROPRIAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'V', 'V');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'V', 'V');
    elsif (perf.codigo = 'I_TAR_AV_ESTORNAR_CUSTOS_RECEITAS_PROPRIAS') then
      pck_migra.p_perfil_permis(perf.perfil_id, 1, 'V', 'E');
      pck_migra.p_perfil_permis(perf.perfil_id, 2, 'V', 'E');
    end if;   
  end loop;
  pck_migra.p_perfil_fim;
  -- fim migração perfil
  
  -- Migra permissões de custos em papeis 
  for pap in (select pip.papel_projeto_id, pip.tipo_acesso, 
                     pi.permissao_item_id, pi.codigo
                from permissao_item pi,
                     permissao_item_papel pip
               where pip.permissao_item_id = pi.permissao_item_id
                 and pi.codigo like '%CUSTO%') loop
    -- projeto
    if (pap.codigo = 'I_PROJETO_PLANEJAR_CUSTOS_RECEITAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'P', 'I');
    elsif (pap.codigo = 'I_PROJETO_REALIZAR_CUSTOS_RECEITAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'P', 'I');
    elsif (pap.codigo = 'I_PROJETO_VISUALIZAR_CUSTOS_RECEITAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'P', 'V');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'P', 'V');
    elsif (pap.codigo = 'I_PROJETO_ESTORNAR_CUSTOS_RECEITAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'P', 'E');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'P', 'E');
    -- atividade
    elsif (pap.codigo = 'I_ATIVIDADE_PLANEJAR_CUSTOS_RECEITAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'A', 'I');
    elsif (pap.codigo = 'I_ATIVIDADE_REALIZAR_CUSTOS_RECEITAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'A', 'I');
    elsif (pap.codigo = 'I_ATIVIDADE_VISUALIZAR_CUSTOS_RECEITAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'A', 'V');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'A', 'V');
    elsif (pap.codigo = 'I_ATIVIDADE_ESTORNAR_CUSTOS_RECEITAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'A', 'E');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'A', 'E');
    -- tarefa de projeto 
    elsif (pap.codigo = 'I_TAR_PROJ_PLANEJAR_CUSTOS_RECEITAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'T', 'I');
    elsif (pap.codigo = 'I_TAR_PROJ_REALIZAR_CUSTOS_RECEITAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'T', 'I');
    elsif (pap.codigo = 'I_TAR_PROJ_VISUALIZAR_CUSTOS_RECEITAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'T', 'V');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'T', 'V');
    elsif (pap.codigo = 'I_TAR_PROJ_ESTORNAR_CUSTOS_RECEITAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'T', 'E');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'T', 'E');
    -- tarefa de projeto
    elsif (pap.codigo = 'I_TAR_AV_PLANEJAR_CUSTOS_RECEITAS_PROPRIAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'V', 'I');
    elsif (pap.codigo = 'I_TAR_AV_REALIZAR_CUSTOS_RECEITAS_PROPRIAS') then      
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'V', 'I');
    elsif (pap.codigo = 'I_TAR_AV_VISUALIZAR_CUSTOS_RECEITAS_PROPRIAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'V', 'V');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'V', 'V');
    elsif (pap.codigo = 'I_TAR_AV_ESTORNAR_CUSTOS_RECEITAS_PROPRIAS') then
      pck_migra.p_papel_permis(pap.papel_projeto_id, 1, 'V', 'E');
      pck_migra.p_papel_permis(pap.papel_projeto_id, 2, 'V', 'E');
    end if;             
  end loop;
  pck_migra.p_papel_fim;
  -- fim migração papel
  
  -- Permissões em formulários de demandas
  for form in (select cf.chave_campo, cf.regra_id, cf.formulario_id
                 from campo_formulario cf
                where cf.chave_campo like '%CUSTO%'
                  and cf.regra_id is not null) loop
    if (form.chave_campo = 'REALIZAR_CUSTO_RECEITA') then
      pck_migra.form_permis(form.formulario_id, 2, 'I', form.regra_id);
      pck_migra.form_permis(form.formulario_id, 2, 'V', form.regra_id);
    elsif (form.chave_campo = 'ESTORNAR_CUSTO_RECEITA') then
      pck_migra.form_permis(form.formulario_id, 1, 'E', form.regra_id);
      pck_migra.form_permis(form.formulario_id, 2, 'E', form.regra_id); 
    elsif (form.chave_campo = 'PLANEJAR_CUSTO_RECEITA') then
      pck_migra.form_permis(form.formulario_id, 1, 'I', form.regra_id);
      pck_migra.form_permis(form.formulario_id, 1, 'V', form.regra_id);
    end if;           
  end loop;
  -- Atribui permissão de edição que bloqueia o acesso
  for form in (select * 
                 from campo_formulario cf
                where visivel = 'N' 
                  and cf.chave_campo like '%CUSTO%') loop
    if (form.chave_campo = 'REALIZAR_CUSTO_RECEITA') then
      pck_migra.form_permis(form.formulario_id, 2, 'I', 0);
      pck_migra.form_permis(form.formulario_id, 2, 'V', 0);
    elsif (form.chave_campo = 'ESTORNAR_CUSTO_RECEITA') then
      pck_migra.form_permis(form.formulario_id, 1, 'E', 0);
      pck_migra.form_permis(form.formulario_id, 2, 'E', 0); 
    elsif (form.chave_campo = 'PLANEJAR_CUSTO_RECEITA') then
      pck_migra.form_permis(form.formulario_id, 1, 'I', 0);
      pck_migra.form_permis(form.formulario_id, 1, 'V', 0);
    end if;    
    
  end loop;
  
  
end;
/

commit;
/

drop package pck_migra;


