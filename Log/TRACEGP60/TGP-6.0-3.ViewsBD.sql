/******************************************************************************\
* Script para criação de novas views (versão calendário)                       *
* AUTOR: Charles Falcão                              DATA: 27/11/2009          *
\******************************************************************************/

--------------------------------------------------------------------------------
create or replace force view v_dias_futuros as 
select data as dia from dia;
--------------------------------------------------------------------------------
--create or replace force view v_dias_futuros as 
--select add_months(trunc(sysdate),240)-level+1 dia
--  from dual 
--connect by add_months(trunc(sysdate),240)-level+1 >= to_date('20000101','yyyymmdd');
--------------------------------------------------------------------------------
create or replace force view v_diretorio_equipe as 
select distinct usuarioid usuario_id, projetoid projeto_id
  from papelprojetorecurso;
--------------------------------------------------------------------------------
create or replace force view v_tipo_profissional_vigente as 
  select id, descricao, vigente, valorhora, padraohorario 
  from tipoprofissional
 where vigente = 'S';
--------------------------------------------------------------------------------
create or replace force view v_calendario_dependente as 
select nivel, id calendario_id, to_number(substr(path, 2, 11)) calendario_dep_id,
       carga_horaria
  from ( select level nivel, sys_connect_by_path(to_char(c.id, '9999999999'), '-') path,
                c.id, c.carga_horaria
           from calendario c
          where c.tipo = 'B'
         connect by c.id = prior c.pai_id );
--------------------------------------------------------------------------------
create or replace force view v_regra_calendario_detalhe as 
select vd.dia data, rc.id id,  rc.descricao descricao, rc.usuario_id usuario_id, 
       rc.calendario_id calendario_id,rc.projeto_id projeto_id, rc.periodo periodo, 
       decode(rc.periodo, 'U', rc.carga_horaria, 0) carga_horaria, 
       rc.tipo_periodo_n_util tipo_periodo_n_util, rc.frequencia frequencia, 
       decode(rc.frequencia, 'U', 1, 'A', 2, 'M', 3, 'S', 4, 9999999) ordem,
       rc.frequencia_numero, rc.frequencia_data, rc.vigencia_inicial,
       rc.vigencia_final, rc.titulo, rc.freq_domingo, rc.freq_segunda, 
       rc.freq_terca, rc.freq_quarta, rc.freq_quinta, rc.freq_sexta,
       rc.freq_sabado
  from regra_calendario  rc,
       v_dias_futuros    vd
 where vd.dia between rc.vigencia_inicial and rc.vigencia_final
   and 'Y' = decode (to_char(vd.dia,'d'), 
                     '1', rc.freq_domingo,
                     '2', rc.freq_segunda,
                     '3', rc.freq_terca,
                     '4', rc.freq_quarta,
                     '5', rc.freq_quinta,
                     '6', rc.freq_sexta,
                     '7', rc.freq_sabado,
                     'N')  
   and (
        -- Regra anual
        ( (rc.frequencia = 'A') and (to_char(rc.frequencia_data,'ddmm') = to_char(vd.dia,'ddmm')) )
        or
        -- Regra mensal 
        ( (rc.frequencia = 'M') and ( to_number(to_char(vd.dia,'dd')) = rc.frequencia_numero
                                     or 
                                      (to_number(to_char(vd.dia+1,'dd')) = 1 
                                       and rc.frequencia_numero = 32) 
                                    ) )
        or 
        -- Demais regras
        (rc.frequencia not in ('A', 'M'))
       );
--------------------------------------------------------------------------------
create or replace force view v_regra_calendario_base as 
select vcd.calendario_dep_id calendario_id, vrcd.data, vrcd.id regra_id, 
       decode(vcd.calendario_id, vcd.calendario_dep_id, 'D', 'H') escopo,
       vrcd.periodo, vrcd.carga_horaria, vrcd.tipo_periodo_n_util,
       vrcd.frequencia, vrcd.frequencia_numero, vrcd.frequencia_data, 
       vrcd.vigencia_inicial, vrcd.vigencia_final, vrcd.descricao, vrcd.titulo,
       decode(vrcd.frequencia, 'C', 1000, 0) + vrcd.ordem + (vcd.nivel * 10) ordem,
       null usuario_id, null projeto_id, vrcd.freq_domingo, vrcd.freq_segunda, 
       vrcd.freq_terca, vrcd.freq_quarta, vrcd.freq_quinta, vrcd.freq_sexta,
       vrcd.freq_sabado
  from v_regra_calendario_detalhe vrcd,
       v_calendario_dependente    vcd
 where vrcd.calendario_id = vcd.calendario_id
   and vrcd.usuario_id is null
   and vrcd.projeto_id is null;
--------------------------------------------------------------------------------
create or replace force view v_regra_calendario_usuario as 
select vrcd.usuario_id, vrcd.data, vrcd.id regra_id, 'D' escopo,
       vrcd.periodo, vrcd.carga_horaria, vrcd.tipo_periodo_n_util,
       vrcd.frequencia, vrcd.frequencia_numero, vrcd.frequencia_data, 
       vrcd.vigencia_inicial, vrcd.vigencia_final, vrcd.descricao, 
       vrcd.ordem, vrcd.titulo, null calendario_id, null projeto_id,
       vrcd.freq_domingo, vrcd.freq_segunda, vrcd.freq_terca, vrcd.freq_quarta, 
       vrcd.freq_quinta, vrcd.freq_sexta, vrcd.freq_sabado
  from v_regra_calendario_detalhe vrcd
 where vrcd.usuario_id    is not null
   and vrcd.projeto_id    is null
   and vrcd.calendario_id is null
union  
select u.usuarioid, vrcb.data, vrcb.regra_id, 'H',
       vrcb.periodo, vrcb.carga_horaria, vrcb.tipo_periodo_n_util,
       vrcb.frequencia, vrcb.frequencia_numero, vrcb.frequencia_data, 
       vrcb.vigencia_inicial, vrcb.vigencia_final, vrcb.descricao, vrcb.ordem,
       vrcb.titulo, vrcb.calendario_id calendario_id, null projeto_id,
       vrcb.freq_domingo, vrcb.freq_segunda, vrcb.freq_terca, vrcb.freq_quarta, 
       vrcb.freq_quinta, vrcb.freq_sexta, vrcb.freq_sabado
  from usuario                       u,
       v_regra_calendario_base vrcb
 where u.calendario_base_id = vrcb.calendario_id;
--------------------------------------------------------------------------------
create or replace force view v_regra_calendario_projeto as 
  select vrcd.projeto_id, vrcd.data, vrcd.id regra_id, 'D' escopo,
       vrcd.periodo, vrcd.carga_horaria, vrcd.tipo_periodo_n_util,
       vrcd.frequencia, vrcd.frequencia_numero, vrcd.frequencia_data, 
       vrcd.vigencia_inicial, vrcd.vigencia_final, vrcd.descricao, vrcd.ordem,
       vrcd.titulo, null usuario_id, vrcd.calendario_id, vrcd.freq_domingo, 
       vrcd.freq_segunda, vrcd.freq_terca, vrcd.freq_quarta, vrcd.freq_quinta, 
       vrcd.freq_sexta, vrcd.freq_sabado
  from v_regra_calendario_detalhe vrcd
 where vrcd.usuario_id    is null
   and vrcd.projeto_id    is not null;
--------------------------------------------------------------------------------
create or replace force view v_regra_calendario_recurso as 
  select vrcd.usuario_id, vrcd.projeto_id, vrcd.data, vrcd.id regra_id, 'D' escopo,
       vrcd.periodo, vrcd.carga_horaria, vrcd.tipo_periodo_n_util,
       vrcd.frequencia, vrcd.ordem, vrcd.frequencia_numero, 
       vrcd.frequencia_data, vrcd.vigencia_inicial, vrcd.vigencia_final, 
       vrcd.descricao, vrcd.titulo, null calendario_id, vrcd.freq_domingo, 
       vrcd.freq_segunda, vrcd.freq_terca, vrcd.freq_quarta, vrcd.freq_quinta, 
       vrcd.freq_sexta, vrcd.freq_sabado
  from v_regra_calendario_detalhe vrcd
 where vrcd.usuario_id    is not null
   and vrcd.projeto_id    is not null
   and vrcd.calendario_id is null
union  
-- regras do usuário
select ppr.usuarioid, ppr.projetoid, vrcu.data, vrcu.regra_id, 'H',
       vrcu.periodo, vrcu.carga_horaria, vrcu.tipo_periodo_n_util,
       vrcu.frequencia, vrcu.ordem, vrcu.frequencia_numero, 
       vrcu.frequencia_data, vrcu.vigencia_inicial, vrcu.vigencia_final, 
       vrcu.descricao, vrcu.titulo, null, vrcu.freq_domingo, vrcu.freq_segunda, 
       vrcu.freq_terca, vrcu.freq_quarta, vrcu.freq_quinta, vrcu.freq_sexta,
       vrcu.freq_sabado
  from v_regra_calendario_usuario vrcu,
       papelprojetorecurso        ppr
 where vrcu.usuario_id = ppr.usuarioid
union
-- regras do projeto
select ppr.usuarioid, ppr.projetoid, vrcp.data, vrcp.regra_id, 'H',
       vrcp.periodo, vrcp.carga_horaria, vrcp.tipo_periodo_n_util,
       vrcp.frequencia, vrcp.ordem, vrcp.frequencia_numero, 
       vrcp.frequencia_data, vrcp.vigencia_inicial, vrcp.vigencia_final, 
       vrcp.descricao, vrcp.titulo, null, vrcp.freq_domingo, vrcp.freq_segunda, 
       vrcp.freq_terca, vrcp.freq_quarta, vrcp.freq_quinta, vrcp.freq_sexta,
       vrcp.freq_sabado
  from v_regra_calendario_projeto vrcp,
       papelprojetorecurso        ppr
 where vrcp.projeto_id = ppr.projetoid;
--------------------------------------------------------------------------------
create or replace force view v_regra_cal_recurso_dir as 
select vrcd.usuario_id, vrcd.projeto_id, vrcd.data, vrcd.id regra_id, 'D' escopo,
       vrcd.periodo, vrcd.carga_horaria, vrcd.tipo_periodo_n_util,
       vrcd.frequencia, vrcd.ordem, vrcd.frequencia_numero, 
       vrcd.frequencia_data, vrcd.vigencia_inicial, vrcd.vigencia_final, 
       vrcd.descricao, vrcd.titulo
  from v_regra_calendario_detalhe vrcd
 where vrcd.usuario_id    is not null
   and vrcd.projeto_id    is not null
   and vrcd.calendario_id is null;
--------------------------------------------------------------------------------
create or replace force view v_calendario_base_sr as 
select vd.dia data, 
       decode(to_char(vd.dia, 'd'), 1, 'N', 7, 'N', 'U') periodo,
       decode(to_char(vd.dia, 'd'), 1, 0, 7, 0, vcd.carga_horaria) carga_horaria,
       vcd.calendario_dep_id calendario_id
  from v_calendario_dependente vcd,
       v_dias_futuros          vd
 where (vcd.nivel, vcd.calendario_dep_id) in 
                     (select min(vcd1.nivel), vcd1.calendario_dep_id
                        from v_calendario_dependente vcd1
                       where vcd1.carga_horaria is not null
                         and vcd1.calendario_dep_id = vcd.calendario_dep_id
                      group by vcd1.calendario_dep_id);
--------------------------------------------------------------------------------
create or replace force view v_calendario_base as 
select /*+ ordered */
       vcbsr.calendario_id, vcbsr.data, 
       nvl(vrcb.periodo,  vcbsr.periodo) periodo,
       nvl(vrcb.carga_horaria, vcbsr.carga_horaria) carga_horaria,
       vrcb.tipo_periodo_n_util tipo_periodo_n_util,
       vrcb.regra_id regra_id,
       decode(vrcb.regra_id, null, 'N', 'Y') tem_regra,
       vrcb.titulo regra_titulo
  from v_calendario_base_sr    vcbsr,
       v_regra_calendario_base vrcb
 where vcbsr.calendario_id = vrcb.calendario_id (+)
   and vcbsr.data          = vrcb.data          (+)
   and (vrcb.ordem is null or 
        vrcb.ordem = (select min(vrcb1.ordem)
                        from v_regra_calendario_base vrcb1 
                       where vrcb1.calendario_id = vrcb.calendario_id 
                         and vrcb1.data          = vrcb.data));
--------------------------------------------------------------------------------
create or replace force view v_calendario_usuario_sr as 
select vd.dia data, 
       decode(to_char(vd.dia, 'd'), 1, 'N', 7, 'N', 'U') periodo,
       decode(to_char(vd.dia, 'd'), 1, 0, 7, 0, vcd.carga_horaria) carga_horaria,
       u.usuarioid usuario_id
  from v_calendario_dependente vcd,
       v_dias_futuros          vd,
       usuario                 u
 where u.calendario_base_id = vcd.calendario_dep_id
   and (vcd.nivel, vcd.calendario_dep_id) in (select min(vcd1.nivel), vcd1.calendario_dep_id
                                                from v_calendario_dependente vcd1
                                               where vcd1.carga_horaria is not null
                                                 and vcd1.calendario_dep_id = vcd.calendario_dep_id
                                              group by vcd1.calendario_dep_id);
--------------------------------------------------------------------------------
create or replace force view v_calendario_usuario as 
select /*+ ordered */
       vcusr.usuario_id, vcusr.data, 
       nvl(vrcu.periodo,  vcusr.periodo) periodo,
       nvl(vrcu.carga_horaria, vcusr.carga_horaria) carga_horaria,
       vrcu.tipo_periodo_n_util tipo_periodo_n_util,
       vrcu.regra_id regra_id,
       decode(vrcu.regra_id, null, 'N', 'Y') tem_regra,
       vrcu.titulo regra_titulo
  from v_calendario_usuario_sr    vcusr,
       v_regra_calendario_usuario vrcu
 where vcusr.usuario_id = vrcu.usuario_id (+)
   and vcusr.data       = vrcu.data       (+)
   and (vrcu.ordem is null or 
        vrcu.ordem = (select min(vrcu1.ordem)
                        from v_regra_calendario_usuario vrcu1 
                       where vrcu1.usuario_id = vrcu.usuario_id 
                         and vrcu1.data       = vrcu.data));
--------------------------------------------------------------------------------
create or replace force view v_calendario_projeto_sr as 
select vd.dia data, 
       decode(to_char(vd.dia, 'd'), 1, 'N', 7, 'N', 'U') periodo,
       decode(to_char(vd.dia, 'd'), 1, 0, 7, 0, c.carga_horaria) carga_horaria,
       c.id calendario_id, c.projeto_id projeto_id,
       p.datainicio, p.iniciorealizado, p.prazoprevisto, p.prazorealizado
  from projeto        p,  
       calendario     c,
       v_dias_futuros vd
 where c.tipo = 'P'
   and p.id = c.projeto_id;
--------------------------------------------------------------------------------
create or replace force view v_calendario_projeto as 
select vcpsr.projeto_id, vcpsr.data, 
       nvl(vrcp.periodo,  vcpsr.periodo) periodo,
       nvl(vrcp.carga_horaria, vcpsr.carga_horaria) carga_horaria,
       vrcp.tipo_periodo_n_util tipo_periodo_n_util,
       vrcp.regra_id regra_id,
       decode(vrcp.regra_id, null, 'N', 'Y') tem_regra,
       vrcp.titulo regra_titulo,
       vcpsr.datainicio, 
       vcpsr.iniciorealizado, 
       vcpsr.prazoprevisto, 
       vcpsr.prazorealizado
  from v_calendario_projeto_sr    vcpsr,
       v_regra_calendario_projeto vrcp
 where vcpsr.projeto_id = vrcp.projeto_id (+)
   and vcpsr.data       = vrcp.data       (+)
   and (vrcp.ordem is null or 
        vrcp.ordem = (select min(vrcp1.ordem)
                        from v_regra_calendario_projeto vrcp1 
                       where vrcp1.projeto_id = vrcp.projeto_id 
                         and vrcp1.data       = vrcp.data));
--------------------------------------------------------------------------------
create or replace view v_calendario_recurso_sr as
select /*+ ordered */
       vcp.data data,
       decode(vcu.periodo, 'U', decode(vcp.periodo, 'U', 'U', 'N'), 'N') periodo,
       least (nvl(vcu.carga_horaria,0), nvl(vcp.carga_horaria,0)) carga_horaria,
       nvl(vcp.tipo_periodo_n_util, vcu.tipo_periodo_n_util) tipo_periodo_n_util,
       vcu.usuario_id usuario_id, vcp.projeto_id projeto_id,
       case when nvl(vcu.tem_regra,'N') = 'Y' or nvl(vcp.tem_regra,'N') = 'Y'
            then case when nvl(vcu.tem_regra,'N') = 'Y' and vcu.periodo = 'N'
                      then vcu.regra_id
                      else case when nvl(vcp.tem_regra,'N') = 'Y' and vcp.periodo = 'N'
                                then vcu.regra_id
                                else case when nvl(vcu.carga_horaria,0) < nvl(vcp.carga_horaria,0)
                                          then vcu.regra_id
                                          else vcp.regra_id
                                      end
                            end
                  end
            else null
        end regra_id,
       case when nvl(vcu.tem_regra,'N') = 'Y' or nvl(vcp.tem_regra,'N') = 'Y'
            then case when nvl(vcu.tem_regra,'N') = 'Y' and vcu.periodo = 'N'
                      then 'Y'
                      else case when nvl(vcp.tem_regra,'N') = 'Y' and vcp.periodo = 'N'
                                then 'Y'
                                else 'N'
                            end
                  end
            else 'N'
        end tem_regra,
       case when nvl(vcu.tem_regra,'N') = 'Y' or nvl(vcp.tem_regra,'N') = 'Y'
            then case when nvl(vcu.tem_regra,'N') = 'Y' and vcu.periodo = 'N'
                      then vcu.regra_titulo
                      else case when nvl(vcp.tem_regra,'N') = 'Y' and vcp.periodo = 'N'
                                then vcu.regra_titulo
                                else case when nvl(vcu.carga_horaria,0) < nvl(vcp.carga_horaria,0)
                                          then vcu.regra_titulo
                                          else vcp.regra_titulo
                                      end
                            end
                  end
            else null
        end regra_titulo
  from v_calendario_usuario vcu,
       v_calendario_projeto vcp
 where vcu.data = vcp.data;
--------------------------------------------------------------------------------
create or replace view v_calendario_recurso as
select vcrsr.usuario_id, vcrsr.projeto_id, vcrsr.data,
       case when nvl(vrcrd.frequencia,' ') <> 'C'
            then nvl(vrcrd.periodo,  vcrsr.periodo)
            else case when nvl(vrcrd.frequencia,' ') = 'C'
                           and vcrsr.tem_regra       = 'N'
                           and vcrsr.periodo         = 'U'
                      then vrcrd.periodo
                      else vcrsr.periodo
                  end
        end periodo,
       case when nvl(vrcrd.frequencia,' ') <> 'C'
            then nvl(vrcrd.carga_horaria, vcrsr.carga_horaria)
            else case when nvl(vrcrd.frequencia,' ') = 'C'
                           and vcrsr.tem_regra       = 'N'
                           and vcrsr.periodo         = 'U'
                      then vrcrd.carga_horaria
                      else vcrsr.carga_horaria
                  end
        end carga_horaria,
       case when (nvl(vrcrd.frequencia,' ') = 'C'
                  and vcrsr.tem_regra       = 'N'
                  and vcrsr.periodo         = 'U')
                 or (nvl(vrcrd.frequencia,'C') <> 'C')
            then vrcrd.tipo_periodo_n_util
            else vcrsr.tipo_periodo_n_util
        end tipo_periodo_n_util,
       case when nvl(vrcrd.frequencia,'C') <> 'C'
            then vrcrd.regra_id
            else vcrsr.regra_id
        end regra_id,
       case when nvl(vrcrd.frequencia,'C') <> 'C'
            then decode(vrcrd.regra_id, null, 'N', 'Y')
            else vcrsr.tem_regra
        end tem_regra,
       case when nvl(vrcrd.frequencia,'C') <> 'C'
            then vrcrd.titulo
            else vcrsr.regra_titulo
        end regra_titulo
  from  v_calendario_recurso_sr vcrsr,
        v_regra_cal_recurso_dir vrcrd
 where vcrsr.usuario_id = vrcrd.usuario_id (+)
   and vcrsr.projeto_id = vrcrd.projeto_id (+)
   and vcrsr.data       = vrcrd.data       (+)
   and (vrcrd.ordem is null or
        vrcrd.ordem = (select min(vrcrd1.ordem)
                         from v_regra_cal_recurso_dir vrcrd1
                        where vrcrd1.usuario_id = vrcrd.usuario_id
                          and vrcrd1.projeto_id = vrcrd.projeto_id
                          and vrcrd1.data       = vrcrd.data) );
--------------------------------------------------------------------------------
create or replace force view v_carga_horaria_padrao_usuario as 
select u.usuarioid usuario_id, 
       nvl(vcd.carga_horaria,0) carga_horaria
  from v_calendario_dependente vcd,
       usuario                 u
 where u.calendario_base_id = vcd.calendario_dep_id
   and (vcd.nivel, vcd.calendario_dep_id) 
                      in (select min(vcd1.nivel), vcd1.calendario_dep_id
                            from v_calendario_dependente vcd1
                           where vcd1.carga_horaria is not null
                             and vcd1.calendario_dep_id = vcd.calendario_dep_id
                          group by vcd1.calendario_dep_id);
--------------------------------------------------------------------------------
create or replace force view v_carga_horaria_padrao_recurso as 
select x.projeto_id projeto_id, x.usuario_id usuario_id, 
       nvl(rc.carga_horaria,x.carga_horaria) carga_horaria
  from regra_calendario rc,
       (select c.projeto_id projeto_id, u.usuarioid usuario_id, 
               least(nvl(vcd.carga_horaria,0), nvl(c.carga_horaria,0)) carga_horaria
          from v_calendario_dependente vcd,
               usuario                 u,
               calendario              c
         where c.tipo = 'P'
           and u.calendario_base_id = vcd.calendario_dep_id
           and (vcd.nivel, vcd.calendario_dep_id) 
                              in (select min(vcd1.nivel), vcd1.calendario_dep_id
                                    from v_calendario_dependente vcd1
                                   where vcd1.carga_horaria is not null
                                     and vcd1.calendario_dep_id = vcd.calendario_dep_id
                                  group by vcd1.calendario_dep_id)) x
 where rc.projeto_id (+) = x.projeto_id
   and rc.usuario_id (+) = x.usuario_id
   and rc.frequencia (+) = 'C';
--------------------------------------------------------------------------------
create or replace force view v_alocacao_tarefa_resumo as 
select ha.tarefa_id tarefa_id, re.responsavel usuario_id,  min(ha.data) inicio_alocacao,
       max(ha.data) fim_alocacao, sum(ha.minutos) total_alocacao
  from hora_alocada        ha,
       responsavelentidade re
 where re.tipoentidade  = 'T'
   and re.identidade    = ha.tarefa_id
group by ha.tarefa_id, re.responsavel;
--------------------------------------------------------------------------------
create or replace force view v_alocacao_tarefa as 
select x.data data, x.tarefa_id tarefa_id, nvl(ha.minutos,0) alocacao,
       x.projeto_id projeto_id, x.usuario_id usuario_id, x.papel_id papel_id
  from hora_alocada ha,
       ( select vd.dia data, t.id tarefa_id, t.projeto projeto_id, 
                re.responsavel usuario_id, t.papelprojeto_id papel_id
           from tarefa              t,
                responsavelentidade re,
                v_dias_futuros      vd
          where re.identidade   (+) = t.id
            and re.tipoentidade (+) = 'T'
            and vd.dia between least(t.datainicio, nvl(t.iniciorealizado,t.datainicio)) 
                           and greatest(t.prazoprevisto, 
                                        nvl(t.prazorealizado,to_date('31122099','ddmmyyyy')))) x
 where ha.data (+)      = x.data
   and ha.tarefa_id (+) = x.tarefa_id;
--------------------------------------------------------------------------------
create or replace force view v_alocacao_usuario as 
select /*+ ordered */
       vcu.data, vcu.usuario_id, vcu.carga_horaria carga_horaria,
       sum(nvl(vat.alocacao,0)) alocacao
  from v_calendario_usuario vcu,
       v_alocacao_tarefa    vat
 where vat.data       = vcu.data
   and vat.usuario_id = vcu.usuario_id
group by vcu.data, vcu.usuario_id, vcu.carga_horaria
union
select vcu.data, vcu.usuario_id, vcu.carga_horaria carga_horaria,
       0 alocacao
  from v_calendario_usuario vcu
 where vcu.data not in (select vat.data
                          from v_alocacao_tarefa vat
                         where vat.usuario_id = vcu.usuario_id
                           and vat.data       = vcu.data);
--------------------------------------------------------------------------------
create or replace force view v_alocacao_projeto as
select /*+ ordered */
    vcr.data, vcr.usuario_id, vcr.projeto_id, vcr.carga_horaria carga_horaria,
    sum(nvl(vat.alocacao,0)) alocacao, vcr.periodo periodo, vcr.regra_id regra_id,
    vcr.tipo_periodo_n_util tipo_periodo_n_util, vcr.tem_regra tem_regra
from v_calendario_recurso vcr,
     v_alocacao_tarefa    vat
where vat.data       = vcr.data
  and vat.projeto_id = vcr.projeto_id
  and vat.usuario_id = vcr.usuario_id
group by vcr.data, vcr.usuario_id, vcr.projeto_id, vcr.carga_horaria, vcr.periodo, 
         vcr.regra_id, vcr.tipo_periodo_n_util, vcr.tem_regra
union
select vcr.data, vcr.usuario_id, vcr.projeto_id, vcr.carga_horaria carga_horaria,
    0 alocacao, vcr.periodo periodo, vcr.regra_id regra_id,
    vcr.tipo_periodo_n_util tipo_periodo_n_util, vcr.tem_regra tem_regra
  from v_calendario_recurso vcr
 where vcr.data not in ( select vat.data
                          from v_alocacao_tarefa vat
                         where vat.projeto_id = vcr.projeto_id
                           and vat.usuario_id = vcr.usuario_id
                           and vat.data       = vcr.data );
--------------------------------------------------------------------------------
create or replace force view v_distribuicao_usuario_prj as 
select vde.usuario_id, vcp.data, vcp.projeto_id, vcp.carga_horaria distribuicao
  from v_diretorio_equipe   vde,
       v_calendario_projeto vcp
 where vcp.projeto_id = vde.projeto_id
   and vcp.data between vcp.datainicio and vcp.prazoprevisto;
--------------------------------------------------------------------------------
create or replace force view v_distribuicao_usuario as 
  select vde.usuario_id, vcp.data, sum(vcp.carga_horaria) distribuicao
  from v_diretorio_equipe   vde,
       v_calendario_projeto vcp
 where vcp.projeto_id = vde.projeto_id
   and vcp.data between vcp.datainicio and vcp.prazoprevisto
group by vde.usuario_id, vcp.data;
--------------------------------------------------------------------------------
create or replace view v_dependencia_projetos as 
select nivel grau, to_number(substr(path, 2, 11)) PROJETO_ID, projeto_predecessora 
  from (  select level nivel, projeto_predecessora, 
                 sys_connect_by_path(to_char(dat.projeto,'9999999999'), '-') path
            from dependenciaatividadetarefa dat
           where dat.projeto <> dat.projeto_predecessora 
          connect by prior projeto_predecessora = projeto
                 and prior projeto_predecessora <> prior projeto
          start with projeto <> projeto_predecessora  );
--------------------------------------------------------------------------------
create or replace view v_resp_adm_detalhe as
select u.responsavel_id USUARIO_ID,
       'Registro de Horas' ITEM,
       'Recursos sob sua responsabilidade para aprovação de ajuste de ponto e hora extra' ITEM_DET,
       u.usuarioid ID_DETALHE,
       'USUARIO' TABELA_DETALHE,
       'USUARIOID' CAMPO_TABELA_DETALHE,
       5 TIPO_DETALHE
  from usuario u
union all 
select re.responsavel USUARIO_ID,
       'Tarefas Avulsas' ITEM,
       decode(t.situacao, 0, 'em planejamento',
                          1, 'designadas', 
                          2, 'em andamento',
                          5, 'suspensas',
                          'Erro' ) ITEM_DET,
       to_char(t.id) ID_DETALHE,
       'TAREFA' TABELA_DETALHE,
       'ID' CAMPO_TABELA_DETALHE,
       1 TIPO_DETALHE
  from tarefa              t, 
       responsavelentidade re
 where re.identidade = t.id
   and re.tipoentidade = 'T'
   and t.situacao in (0, 1, 2, 5)
   and t.projeto is null
union all
select d.criador USUARIO_ID,
       'Demandas (não finalizadas)' ITEM,
       'Criadas pelo Usuário' ITEM_DET,
       to_char(d.demanda_id) ID_DETALHE,
       'DEMANDA' TABELA_DETALHE,
       'DEMANDA_ID' CAMPO_TABELA_DETALHE,
       2 TIPO_DETALHE
  from demanda d,
       estado_formulario ef
 where ef.formulario_id = d.formulario_id
   and ef.estado_id     = d.situacao
   and ef.estado_final  <> 'Y'
union all 
select d.solicitante USUARIO_ID,
       'Demandas (não finalizadas)' ITEM,
       'Onde ele é solicitante' ITEM_DET,
       to_char(d.demanda_id) ID_DETALHE,
       'DEMANDA' TABELA_DETALHE,
       'DEMANDA_ID' CAMPO_TABELA_DETALHE,
       2 TIPO_DETALHE
  from demanda d,
       estado_formulario ef
 where ef.formulario_id = d.formulario_id
   and ef.estado_id     = d.situacao
   and ef.estado_final  <> 'Y'
union all 
select d.responsavel USUARIO_ID,
       'Demandas (não finalizadas)' ITEM,
       'Onde ele é responsavel de atendimento' ITEM_DET,
       to_char(d.demanda_id) ID_DETALHE,
       'DEMANDA' TABELA_DETALHE,
       'DEMANDA_ID' CAMPO_TABELA_DETALHE,
       2 TIPO_DETALHE
  from demanda d,
       estado_formulario ef
 where ef.formulario_id = d.formulario_id
   and ef.estado_id     = d.situacao
   and ef.estado_final  <> 'Y'
union all
select da.responsavel,
       'Filtros/Portlets/Dashboards',
       'Dashboards públicos do usuário',
       to_char(da.id),
       'DASHBOARD',
       'ID',
       3
  from dashboard da
 where da.publico = 'Y'
union all 
select f.responsavel,
       'Filtros/Portlets/Dashboards',
       'Filtros públicos do usuário',
       to_char(f.id),
       'FILTRO',
       'ID',
       3
  from filtro f
 where f.publico = 'S'
union all 
select po.responsavel,
       'Filtros/Portlets/Dashboards',
       'Portlets públicos do usuário',
       to_char(po.id),
       'PORTLET',
       'ID',
       3
  from portlet po
 where po.publico = 'Y'
union all
select u.gerente_recurso,
       'Gerência de Recurso',
       'Recursos sob sua responsabilidade',
       u.usuarioid,
       'USUARIO',
       'USUARIOID',
       6
  from usuario u  
union all
select ds.auditor,
       'Cadastro/Configuração',
       'Auditor de destino',
       to_char(ds.destinoid),
       'DESTINO',
       'DESTINOID',
       7
  from destino ds
 where vigente = 'S'
union all
select du.usuario,
       'Cadastro/Configuração',
       'Responsável do destino',
       to_char(du.destino),
       'DESTINO',
       'DESTINOID',
       7       
  from destino_usuario du
union all
select uo.responsavel,
       'Cadastro/Configuração',
       'Primeiro responsável de Unidade Organizacional',
       to_char(uo.id),
       'UO',
       'ID',
       7
  from uo
 where vigente = 'Y'
union all
select uo.responsavel_2,
       'Cadastro/Configuração',
       'Segundo responsável de Unidade Organizacional',
       to_char(uo.id),
       'UO',
       'ID',
       7
  from uo
 where vigente = 'Y'
union all
select f.usuario_criador,
       'Cadastro/Configuração',
       'Criador do formulário de demanda',
       to_char(f.formulario_id),
       'FORMULARIO',
       'FORMULARIO_ID',
       7
  from formulario f
union all
select fd.auditor,
       'Cadastro/Configuração',
       'Auditor de destino de formulário',
       to_char(fd.formulario_id)|| ',' || to_char(fd.destino_id),
       'FORMULARIO_DESTINO',  
       'FORMULARIO_ID,DESTINO_ID',
       7   
  from formulario_destino fd
union all
select up.usuarioid,
       'Perfil',
       'Perfis de acesso ao sistema',
       to_char(up.perfilid),
       'PERFIL',
       'PERFILID',
       8
  from usuario_perfil up
union all
select c.idauditor,
       'Cadastro/Configuração',
       'Auditor do Sistema',
       null,
       null,
       null,
       7
  from configuracoes c
 where id = (select max(id) from configuracoes)
union all 
select cd.responsavel,
       'Comunicação',
       'Planos como divulgador',
       to_char(cd.id),
       'COMUNICACAO_DASHBOARD',
       'ID',
       4
  from comunicacao_dashboard cd
 where vigente = 'Y'  
union all
select ei.usuario,
       'Comunicação',
       'Planos como interessado',
       to_char(ei.entidade_id),
       'COMUNICACAO_DASHBOARD',
       'ID',
       4       
  from email_interessado ei
 where ei.tipo_entidade = 'N'
   and ei.tipo_usuario  = 'I';
 
create or replace view v_resp_adm as
select usuario_id,
       item,
       item_det,
       tipo_detalhe,
       count(1) quantidade
  from v_resp_adm_detalhe
group by usuario_id, item, item_det, tipo_detalhe;
--------------------------------------------------------------------------------
create or replace view v_resp_projetos_detalhe_all as
-- Responsável por tarefas
select re.responsavel USUARIO_ID,
       t.projeto PROJETO_ID,
       'Responsável por tarefas ' ||  
       decode(t.situacao, 0, 'em planejamento',
                          1, 'designadas', 
                          2, 'em andamento',
                          5, 'suspensas',
                          'Erro' ) ITEM,
       t.id ID_DETALHE,
       'TAREFA' TABELA_DETALHE,
       'ID' CAMPO_TABELA_DETALHE,
       1 TIPO_DETALHE
  from tarefa              t, 
       responsavelentidade re
 where re.identidade = t.id
   and re.tipoentidade = 'T'
   and t.situacao in (0, 1, 2, 5)
   and t.projeto is not null
union all
-- Responsável por atividades
select re.responsavel USUARIO_ID,
       a.projeto PROJETO_ID,
       'Responsável por atividades ' ||  
       decode(a.situacao, 0, 'em planejamento',
                          1, 'designadas', 
                          2, 'em andamento',
                          5, 'suspensas',
                          'Erro' ) ITEM,
       a.id ID_DETALHE,
       'ATIVIDADE' TABELA_DETALHE,
       'ID' CAMPO_TABELA_DETALHE,
       1 TIPO_DETALHE
  from atividade           a, 
       responsavelentidade re
 where re.identidade = a.id
   and re.tipoentidade = 'A'
   and a.situacao in (0, 1, 2, 5)
union all
-- Responsável por projetos
select re.responsavel USUARIO_ID,
       p.id PROJETO_ID,
       'Responsável por projetos ' ||  
       decode(p.situacao, 0, 'em planejamento',
                          1, 'designadas', 
                          2, 'em andamento',
                          5, 'suspensas',
                          'Erro' ) ITEM,
       p.id ID_DETALHE,
       'PROJETO' TABELA_DETALHE,
       'ID' CAMPO_TABELA_DETALHE,
       1 TIPO_DETALHE
  from projeto             p, 
       responsavelentidade re
 where re.identidade = p.id
   and re.tipoentidade = 'P'
   and p.situacao in (0, 1, 2, 5)
union all
-- Escopo (aprovador)
select ae.aprovador USUARIO_ID,
       ae.projeto PROJETO_ID,
       'Usuário aprovados de escopo' ITEM,
       ae.projeto ID_DETALHE,
       'PROJETO',
       'ID',
       2 TIPO_DETALHE
  from aprovadorescopo ae
union all
-- Atividade (aprovador)
select ae.aprovador,
       a.projeto,
       'Usuário aprovador de atividades',
       a.id,
       'ATIVIDADE',
       'ID',
       3 TIPO_DETALHE
  from aprovadorentidade ae,
       atividade a
 where ae.tipoentidade = 'A'
   and ae.identidade   = a.id
union all
-- Atividade (vistoriador)
select ve.vistoriador,
       a.projeto,
       'Usuário vistoriador de atividades',
       a.id,
       'ATIVIDADE',
       'ID',
       3 TIPO_DETALHE
  from vistoriadorentidade ve,
       atividade a
 where ve.tipoentidade = 'A'
   and ve.identidade   = a.id
union all
-- Stakeholder
select stakeholderid,
       projetoid,
       'Usuário stakeholder',
       projetoid,
       'PROJETO',
       'ID',
       2 TIPO_DETALHE
  from stakeholder
union all
-- Riscos
select responsavel,
       projetoid,
       'Riscos sob sua responsabilidade',
       riscoid,
       'RISCO',
       'RISCOID',
       4 TIPO_DETALHE
  from risco
union all
-- Papéis em projetos
select usuarioid,
       projetoid,
       'Papéis diversos nos projetos',
       papelid,
       'PAPELPROJETORECURSO',
       'PAPELID',
       5 TIPO_DETALHE
  from papelprojetorecurso ppr
union all
-- Notificações pendentes
select nee.usuarioid,
       nee.projeto,
       'Participante das notificações - Plano Comunicações',
       nee.notificacaoid,
       'NOTIFICACAO_ESTADO_ENTIDADE',
       'NOTIFICACAOID',
       7
  from notificacao_estado_entidade nee
 where projeto is not null
union all
-- 
select ei.usuario,
       ei.entidade_id,
       'Participante das Notificações - Troca Estado',
       ei.entidade_id,
       decode(ei.tipo_entidade, 'P', 'PROJETO', 'A', 'ATIVIDADE', 'T', 'TAREFA', null),
       'ID',
       8 
  from email_interessado ei
 where tipo_entidade in ('P', 'A', 'T')
   and tipo_usuario  = 'I'
;
--------------------------------------------------------------------------------
create or replace view v_resp_projetos_detalhe as
select usuario_id,
       projeto_id,
       item,
       id_detalhe,
       tabela_detalhe,
       campo_tabela_detalhe,
       tipo_detalhe
  from v_resp_projetos_detalhe_all,
       projeto
 where projeto_id = id
   and situacao in (0, 1, 2, 5);
--------------------------------------------------------------------------------
create or replace view v_resp_projetos as
select usuario_id,
       projeto_id,
       item,
       tipo_detalhe,
       count(1) quantidade
  from v_resp_projetos_detalhe,
       projeto
 where projeto_id = id
   and situacao in (0, 1, 2, 5)
group by usuario_id, projeto_id, item, tipo_detalhe;
--------------------------------------------------------------------------------
create or replace view v_responsabilidade as
select usuario_id,
       item,
       tipo_detalhe,
       count(1) quantidade
  from v_resp_projetos_detalhe,
       projeto
 where projeto_id = id
   and situacao in (0, 1, 2, 5)
group by usuario_id, item, tipo_detalhe;
--------------------------------------------------------------------------------
create or replace view v_objetivos_indicadores_resumo as
select mi.id id, 'I' TIPO, indicador_template ,mi.entidade_id ENTIDADE_ID, mi.tipo_entidade TIPO_ENTIDADE,
       mi.objetivo_pai OBJETIVO_PAI, mi.titulo TITULO, mi.validade VALIDADE,
       mia.data_apuracao DATA_APURACAO, mia.data_atualizacao DATA_ATUALIZACAO,
       mia.situacao ESTADO, mm.comentario COMENTARIO, mm.valor VALOR_META,
       mi.unidade UNIDADE, mia.escore ESCORE, mia.escore - mm.valor DIFERENCA,
       decode(mm.valor, 0, null, (mia.escore - mm.valor) / mm.valor) DIF_PERC,
       decode(mm.valor, 0, null, mia.escore / mm.valor) PERC_META_ATING,
       mmf.cor COR, mi.descricao DESCRICAO
  from mapa_indicador          mi,
       mapa_indicador_apuracao mia,
       mapa_meta               mm,
       mapa_meta_faixa         mmf
 where mi.id = mia.indicador_id (+)
   and ( ( mia.data_apuracao is null ) or
         ( mia.data_apuracao = nvl( (select max(mia2.data_apuracao)
                                       from mapa_indicador_apuracao mia2
                                      where mia2.indicador_id = mi.id
                                        and mia2.quebra_id is null)
                                   , mia.data_apuracao)))
   -- META
   and mia.indicador_id = mm.indicador_id (+)
   and ( ( mm.data_limite is null ) or
         ( mm.data_limite = nvl( (select min(mm2.data_limite)
                                    from mapa_meta mm2
                                   where mm2.indicador_id = mia.indicador_id
                                     and mm2.data_limite >= mia.data_apuracao
                                     and mm2.quebra_id is null)
                                , mm.data_limite)))
   -- FAIXA
   and mm.indicador_id = mmf.indicador_id (+)
   and ( ( mmf.percentual_meta is null ) or
         ( mmf.percentual_meta = nvl( (select min(mmf2.percentual_meta)
                                         from mapa_meta_faixa mmf2
                                        where mmf2.indicador_id = mm.indicador_id
                                          and mmf2.percentual_meta >= nvl((mia.escore / decode(mm.valor,0,0.0001,mm.valor))*100,0))
                                     , (select max(mmf3.percentual_meta)
                                         from mapa_meta_faixa mmf3))))
union all
select mo.id id, 'O' TIPO,'N' indicador_template, mo.entidade_id ENTIDADE_ID, mo.tipo_entidade TIPO_ENTIDADE,
       mo.objetivo_pai OBJETIVO_PAI, mo.titulo TITULO, mo.validade VALIDADE,
       moa.data_apuracao DATA_APURACAO, moa.data_atualizacao DATA_ATUALIZACAO,
       moa.situacao ESTADO, mom.comentario COMENTARIO, mom.valor VALOR_META,
       mo.unidade UNIDADE, moa.escore ESCORE, moa.escore - mom.valor DIFERENCA,
       decode(mom.valor, 0, null, (moa.escore - mom.valor) / mom.valor) DIF_PERC,
       decode(mom.valor, 0, null, moa.escore / mom.valor) PERC_META_ATING,
       mof.cor COR, mo.descricao DESCRICAO
  from mapa_objetivo           mo,
       mapa_objetivo_apuracao  moa,
       mapa_objetivo_meta      mom,
       mapa_objetivo_faixa     mof
 where mo.id = moa.objetivo_id (+)
   and ( ( moa.data_apuracao is null ) or
         ( moa.data_apuracao = nvl( (select max(moa2.data_apuracao)
                                       from mapa_objetivo_apuracao moa2
                                      where moa2.objetivo_id = mo.id)
                                   , moa.data_apuracao)))
   -- META
   and moa.objetivo_id = mom.objetivo_id (+)
   and ( ( mom.data_limite is null ) or
         ( mom.data_limite = nvl( (select min(mom2.data_limite)
                                     from mapa_objetivo_meta mom2
                                    where mom2.objetivo_id = moa.objetivo_id
                                      and mom2.data_limite >= moa.data_apuracao)
                                 , mom.data_limite)))
   -- FAIXA
   and mom.objetivo_id = mof.objetivo_id (+)
   and ( ( mof.percentual_meta is null ) or
         ( mof.percentual_meta = nvl( (select min(mof2.percentual_meta)
                                         from mapa_objetivo_faixa mof2
                                        where mof2.objetivo_id = mom.objetivo_id
                                          and mof2.percentual_meta >= nvl((moa.escore / decode(mom.valor,0,0.0001,mom.valor))*100,0))
                                     , (select max(mmf3.percentual_meta)
                                         from mapa_meta_faixa mmf3))));
-------------------------------------------------------------------------------
create or replace view v_objetivos_subordinados as
select nivel,
       to_number(substr(path, 2, 11)) OBJETIVO_ID,
       objetivo_agrupado_id OBJETIVO_SUBORDINADO_ID,
       'AGRUPAMENTO' TIPO_HIERARQUIA
  from (select level nivel, sys_connect_by_path(to_char(moa.objetivo_id_agrupador,'9999999999'), '-') path,
               moa.objetivo_id_agrupado OBJETIVO_AGRUPADO_ID
          from mapa_objetivo_agrupador moa
        connect by moa.objetivo_id_agrupador = prior moa.objetivo_id_agrupado)
union all
select nivel,
       to_number(substr(path, 2, 11)) OBJETIVO_ID,
       objetivo_id OBJETIVO_SUBORDINADO_ID,
       'PAI-FILHO' TIPO_HIERARQUIA
  from (select level nivel, sys_connect_by_path(to_char(mo.objetivo_pai,'9999999999'), '-') path,
               mo.id OBJETIVO_ID
          from mapa_objetivo mo
        connect by prior mo.id = mo.objetivo_pai
        start with mo.objetivo_pai is not null);
