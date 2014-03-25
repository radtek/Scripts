create sequence regras_lista_temp_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
alter table FORMULARIO add CONTROLE_AGENDAMENTO_T_E varchar2(1) default 'N';

create table AGENDAMENTO_TRANSICAO_ESTADO (
       id number(10) not null,
       formulario_id number(10),
       demanda_id number(10),
       data_inicio date,
       estado_inicio number(10),
       data_fim date,
       duracao_dias number(10),
       periodicidade number(10),
       estado_origem number(10),
       estado_destino number(10),
       data_ult_execucao date,
       data_prox_execucao date
);

create table DISP_AGENDAMENTO_TRANS_ESTADO (
       formulario_id number(10) not null,
       estado_id number(10) not null
);

create table REGRA_AGENDAMENTO_TRANS_ESTADO (
      id number(10) not null,
      regra_formulario_id number(10) not null,
      formulario_id number(10) not null,
      tipo varchar2(1) not null
);

comment on column REGRA_AGENDAMENTO_TRANS_ESTADO.tipo is 'Representa se a permissao aplicada é de INCLUSAO = I ou EDICAO E EXCLUSAO = E';

create sequence AGENDAMENTO_TRANSICAO_EST_SEQ increment by 1 start with 1 maxvalue 9999999999 minvalue 1 nocache;

create sequence REGRA_AGENDAMENTO_T_E_SEQ increment by 1 start with 1 maxvalue 9999999999 minvalue 1 nocache;



------- INTEGRACAO ZEUS

Insert into GRUPO (GRUPOID,DESCRICAO,PERSPECTIVA,ORDEM) values (29,'bd.grupo.integracao',1,10);

  Insert into TELA (TELAID,NOME,URL,VISIVEL,GRUPOID,ORDEM,CODIGO,SUBGRUPO,ATALHO) values                     
  (476,'label.prompt.exportacaoDOF','Demandasdo','S',29,1,'CNI_DEMANDAS_DOF','PRIMEIRO','N');

  Insert into TELA (TELAID,NOME,URL,VISIVEL,GRUPOID,ORDEM,CODIGO,SUBGRUPO,ATALHO) values                     
  (477,'label.prompt.exportacaoContabilidade','Demandas.do','S',29,2,'CNI_DEMANDAS_CTB','PRIMEIRO','N');


------- LOG TRANSICAO ESTADOS

create sequence AGENDAMENTO_TRAN_EST_LOG_SEQ 
   increment by 1 start with 1 maxvalue 9999999999 minvalue 1 nocache;

create table AGENDAMENTO_TRANSICAO_EST_LOG (
       id number(10) not null,
       agendamento_id number(10) not null,
       data_execucao DATE default trunc(sysdate) not null,
       demanda_id number(10) not null,
       estado_atual_id number(10) not null,
       estado_destino_id number(10) not null,
       executado varchar2(1) not null,
       mensagem varchar2(2000) null,
       CONSTRAINT "PK_AGEND_TRAN_EST_LOG" PRIMARY KEY ("ID"),
       CONSTRAINT "CHK_AGEND_TRAN_EST_LOG_01" CHECK (executado IN ('N','Y'))
);

alter table AGENDAMENTO_TRANSICAO_ESTADO add constraint PK_AGENDAMENTO_TRANSICAO_EST
  primary key (id); 
  
alter table AGENDAMENTO_TRANSICAO_EST_LOG add constraint FK_AGENDAMENTO_TRAN_EST_LOG_01
  foreign key (agendamento_id) references AGENDAMENTO_TRANSICAO_ESTADO (id);

alter table AGENDAMENTO_TRANSICAO_EST_LOG add constraint FK_AGENDAMENTO_TRAN_EST_LOG_02
  foreign key (estado_destino_id) references ESTADO(ESTADO_ID) on delete cascade;
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PCK_DOCUMENTO AS

type lista_campos is table of t_tipo_campos;

function  f_lista_campos  return lista_campos PIPELINED;
function  f_lista_campos_DOF  return lista_campos PIPELINED;

procedure p_Exporta_Arquivo(ln_ano number,ls_tipo varchar2, ls_projetos varchar2, ln_arquivo in out number);
procedure p_Importa_Arquivo(ln_seq number, ls_diretorio varchar2, ln_retorno in out number);
procedure p_Carrega_Arquivo (ls_diretorio varchar2, ls_arquivo varchar2, ln_seq out number, ln_retorno in out number);
procedure p_Carga_Inicial(ln_seq number, ln_retorno in out number);
procedure p_Importa_Custos(ln_seq number, ln_retorno in out number);
procedure p_Acerto_Carga_Inicial(ln_seq number, ln_retorno in out number);
procedure p_Importa_View_Zeus(ls_diretorio varchar2, ln_retorno in out number);
PROCEDURE p_Exporta_Arquivo_CNI(ls_tipo varchar2, ln_arquivo in out number, ln_retorno in out number);

  
END PCK_DOCUMENTO;
/
CREATE OR REPLACE PACKAGE BODY PCK_DOCUMENTO AS

function  f_lista_campos_DOF  return lista_campos PIPELINED
  as
  begin
     pipe row( t_tipo_campos( 1,'Val_Fixo1'   ,'fixo'  ,1 ,0,'' ,'A'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 2,'Val_Fixo2'   ,'fixo'  ,1 ,0,'' ,'I'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 3,'Cod_Trace'   ,'fixo'  ,5 ,0,'' ,'TRACE'               ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 4,'Val_Fixo4'   ,'fixo'  ,1 ,0,'' ,'1'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 5,'Entidade'    ,'char'  ,10,0,'' ,'TRACETRACE'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 6,'Val_Fixo6'   ,'nulo'  ,0,0 ,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 7,'Dt_Liberacao','date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));
     pipe row( t_tipo_campos( 8,'Valor_Ordem' ,'number',17,2,',','00000000000009D00','Y',''                   ,'Valor da Ordem'));
     pipe row( t_tipo_campos( 9,'Val_Fixo9'   ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(10,'Val_Fixo10'  ,'fixo'  ,1 ,0,'' ,'P'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(11,'Val_Fixo11'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(12,'Dt_Geracao'  ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));
     pipe row( t_tipo_campos(13,'Dt_Provisao' ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Provisao'));
     pipe row( t_tipo_campos(14,'Dt_Pagamento','date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Pagamento'));
     pipe row( t_tipo_campos(15,'Val_Fixo15'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(16,'Val_Fixo16'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(17,'Val_Fixo17'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(18,'Val_Fixo18'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(19,'CTA_Fluxo'   ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(20,'CTA_Ctb'     ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(21,'MOV_CTB'     ,'fixo'  ,5 ,0,'' ,'UU100'               ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(22,'Val_Fixo22'  ,'nulo'  ,0,0 ,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(23,'Texto'       ,'char'  ,200,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(24,'UO'          ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(25,'CR'          ,'char'  ,16,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(26,'Val_Fixo26'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(27,'Val_Fixo27'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(28,'Val_Fixo28'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(29,'Val_Fixo29'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(30,'Val_Fixo30'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(31,'Val_Fixo31'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(32,'Val_Fixo32'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(33,'Dt_Registro' ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));

  end;

function  f_lista_campos  return lista_campos PIPELINED
  as
  begin
         pipe row( t_tipo_campos( 1,'Codigo'   ,'char'  ,4 ,0,'' ,'X'                    ,'Y',''                    ,'Código do Sistema que gerou a informação Orçamento (ORC)') );
         pipe row( t_tipo_campos( 2,'tipo'     ,'number',2 ,0,'' ,'99'                   ,'Y','[2],[3],[4],[5],[6]' ,'Tipo de movimento. Este código é criado no sistema do orçamento e determina a informação, que estará trafegando o movimento. (2  Orçado,3  Realizado,4  Transposto,5  Suplementado,6  Retificado)'));
         pipe row( t_tipo_campos( 3,'ano'      ,'number',4 ,0,'' ,'9999'                 ,'Y',''                    ,'Ano do Orçamento'));
         pipe row( t_tipo_campos( 4,'mes'      ,'date'  ,2 ,0,'' ,'MM'                   ,'Y',''                    ,'Mês do Orçamento'));
         pipe row( t_tipo_campos( 5,'cod_empre','number',3 ,0,'' ,'999'                  ,'Y',''                    ,'Código da Empresa do Movimento'));
         pipe row( t_tipo_campos( 6,'Cod_UO'   ,'char'  ,10,0,'' ,'X '                   ,'Y',''                    ,'Código da Unidade Organizacional'));
         pipe row( t_tipo_campos( 7,'Cod_CR'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Centro de Responsabilidade'));
         pipe row( t_tipo_campos( 8,'Cod_CO'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Conta Orçamentária'));
         pipe row( t_tipo_campos( 9,'Qtde_Mov' ,'number',17,4,',','000000000009D0000'    ,'Y',''                    ,'Quantidade do Movimento'));
         pipe row( t_tipo_campos(10,'Val_Mov'  ,'number',17,2,',','00000000000009D00'    ,'Y',''                    ,'Valor do Movimento'));
         pipe row( t_tipo_campos(11,'Val_Fixo' ,'fixo'  ,1 ,0,'' ,'0'                    ,'Y',''                    ,'Valor_Fixo'));
         pipe row( t_tipo_campos(12,'Nome_Arq' ,'char'  ,4 ,0,'' ,'X '                   ,'Y',''                    ,'Nome do arquivo do movimento orçamentário'));
         pipe row( t_tipo_campos(13,'Ano_PC'   ,'date'  ,4 ,0,'' ,'YYYY'                 ,'Y',''                    ,'Ano do Plano de Contas'));
         pipe row( t_tipo_campos(14,'Cod_CC'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Conta Contábil'));
         pipe row( t_tipo_campos(15,'Cod_Mov'  ,'char'  ,1 ,0,'' ,'X'                    ,'Y','[A],[M]'             ,'Determina a forma da entrada do movimento do orçamento. Todos os movimentos atuais são automáticos M  Manual A - Automático'));
         pipe row( t_tipo_campos(16,'Dt_Mov'   ,'date'  ,19,0,'' ,'DD/MM/YYYY HH24:MI:SS','Y',''                    ,'Data de Atualização do Movimento'));

  end;

PROCEDURE p_Exporta_Arquivo(ln_ano number,
                            ls_tipo varchar2, 
                            ls_projetos varchar2, 
                            ln_arquivo in out number) AS

 ls_campo              VARCHAR2(2000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(32000);
begin

/*
--Para Testes:

ls_query:='
select ''ORC'',
        1, -- Orçado
        cl.data,
        cl.data,
        level, --number Empresa 
        ''A'', --UO
        ''CR'', --C responsa
        ''11'', --Cta Orçamentaria
        nvl(cl.quantidade,0),
        cl.valor,
        ''0'', --fixo
        ''Teste.txt'',
        sysdate,
        nvl(td.conta_contabil,''0''),
        ''M'',
        sysdate
from custo_entidade ce, custo_lancamento cl, tipodespesa td
where cl.custo_entidade_id = ce.id and
      td.id = ce.tipo_despesa_id CONNECT BY level <= 100 ';
*/

 ls_query:='
 select ''ORC'',
        case ''' || ls_tipo || '''
          when ''Planejamento'' then 2 
          when ''Realizado'' then 3
          when ''Transposição'' then 4
          when ''Suplementação'' then 5
          when ''Retificação'' then 6 END Tipo,
        '|| to_char(ln_ano) ||' Ano, --ln_ano
        cl.data Mes,
        case substr(u.titulo,5,2) 
          when ''01'' then 100 
          when ''02'' then 200
          when ''03'' then 300
          when ''04'' then 400
          when ''05'' then 500 
          else 0 end Empresa ,
        substr(u.titulo,5,instr(u.titulo,''-'')-6) UO,
        nvl((select substr(cia.Titulo,6,instr(cia.Titulo,''-'')-6) 
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = b.projeto_id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=2 and
                         cia.atributo_id=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id
                         ),''0000000000'') ||
        nvl((select 
                lpad(trim(to_char(trunc(aev.ValorNumerico))),  trunc((length(trim(to_char(trunc(aev.ValorNumerico))))+1)/2)*2   ,''0'')        
                from atributoentidadevalor aev 
                   where aev.identidade = b.projeto_id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=1),''000000'') CentroResponsabilidadeSEQ, 
        substr(cr.titulo,6,instr(cr.titulo,''-'')-7) Cta_Orc, 
        nvl(cl.quantidade,0) Qtde,
        cl.valor Valor,
        ''0'' Fixo, 
        ''' || ls_tipo || '-'||to_char(ln_ano)||'.TXT'' Arquivo,
        sysdate Ano_Plano_Contas,
        ''0'' Cta_contabil,
        ''A'' Automatico,
        sysdate Dt_Atualizacao
     from baseline b, 
          baseline_custo_entidade ce, 
          baseline_custo_lancamento cl, 
          custo_receita cr,
          projeto p, 
          uo u
     where b.titulo =  '''|| ls_tipo|| '-' || to_char(ln_ano) || ''' and
           b.projeto_id in ('|| replace(ls_projetos,'-',',')||')   and
           b.baseline_id = ce.baseline_id and
           b.baseline_id = cl.baseline_id and
           ce.id = cl.baseline_custo_entidade_id and
           ce.custo_receita_id = cr.id  and
           b.projeto_id = p.id and
           cl.situacao = ''V'' and
           p.uo_id = u.id and
           cl.tipo =''P''';


  DBMS_LOB.CREATETEMPORARY(blob_edit,TRUE);
   
  ls_seperador_campo:=chr(9);
  ls_seperador_registro:=chr(13)||chr(10);
  c := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE (c, ls_query, DBMS_SQL.NATIVE);

  select count(*) into ln_qtde_campos  from table(f_lista_campos);

  FOR i IN 1 .. ln_qtde_campos
    LOOP

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

      BEGIN
        if reg(1).tipo='char' or reg(1).tipo='fixo' then
           DBMS_SQL.define_column(c, i, ls_campo, 2000);
        end if;
        if reg(1).tipo='number' then
           DBMS_SQL.define_column(c, i, ln_campo);
        end if;
        if reg(1).tipo='date' then
           DBMS_SQL.define_column(c, i, ld_campo);
        end if;        

        l_colcnt := i;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1007)
          THEN
            EXIT;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP; 
   DBMS_SQL.define_column(c, 1, ls_campo, 2000);
   fdbk:= DBMS_SQL.EXECUTE (c); 

 LOOP
  EXIT WHEN(DBMS_SQL.fetch_rows(c) <= 0); 

  ls_linha:='';


  FOR i IN 1 .. ln_qtde_campos
      LOOP
     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

     if reg(1).tipo='char' then
        DBMS_SQL.COLUMN_VALUE(c, i, ls_campo);
        if reg(1).formato='X' THEN
           ls_linha := ls_linha || substr(ls_campo,1,reg(1).tamanho);
        end if;
        if reg(1).formato='X ' THEN
           ls_linha := ls_linha || rpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        if reg(1).formato=' X' THEN
           ls_linha := ls_linha || lpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        end if;
     if reg(1).tipo='fixo' then
        ls_linha := ls_linha || reg(1).formato;
     end if;
     if reg(1).tipo='date' then
        DBMS_SQL.COLUMN_VALUE(c, i, ld_campo);
        ls_linha := ls_linha || to_char(ld_campo,reg(1).formato);
     end if;
     if reg(1).tipo='number' then
        DBMS_SQL.COLUMN_VALUE(c, i, ln_campo);
        ls_linha := ls_linha || to_char(ln_campo,reg(1).formato);
     end if;

     if i <> ln_qtde_campos then
        ls_linha :=ls_linha || ls_seperador_campo;
     else
        ls_linha :=ls_linha || ls_seperador_registro;
     end if;
        
      END LOOP;    

    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,trim(ls_tipo)||'-'||to_char(ln_ano)||' Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

 dbms_lob.FREETEMPORARY(blob_edit);

 DBMS_SQL.CLOSE_CURSOR (c);

 ln_arquivo:=ln_doc;

end p_Exporta_Arquivo;

procedure p_Importa_Arquivo(ln_seq       number, 
                            ls_diretorio varchar2,
                            ln_retorno in out number)
is
 ls_campo              VARCHAR2(1000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(2000);
 vtemp                 RAW(32000);
 vend                  NUMBER := 1;
 vlen                  NUMBER := 1;
 vstart                NUMBER := 1;
 vend2                 NUMBER := 1;
 vlen2                 NUMBER := 1;
 vstart2               NUMBER := 1;
 i                     number;
 ln_proj               number:=0;
 bytelen               NUMBER := 32000;
 ultimo_campo          boolean;
 registros             number:=0;     
 ln_ce                 number:=0;
 ln_cl                 number:=0;
 TYPE t_dados IS VARRAY(100) OF varchar2(1000);
 dados t_dados:=t_dados();
 lb_erro boolean:=false;
 ln_categ number;
 ln_uo number;
 -- Modificado <Charles> Ini
 lf_rejeitados SYS.UTL_FILE.file_type;
 lf_log        SYS.UTL_FILE.file_type;
 ln_forma      number := 0;
 ln_tipo       number := 0;
 ln_cr         number := 0;
 ld_lancamento date;
 lv_mensagem   varchar2(4000);
 ld_data_hora  date;
 -- Modificado <Charles> Fim
begin
  
   -- Modificado <Charles> - Ini  
   if ls_diretorio is not null then
     select sysdate into ld_data_hora from dual;
     lf_rejeitados := SYS.UTL_FILE.fopen (ls_diretorio, 'registros_rejeitados_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
     lf_log        := SYS.UTL_FILE.fopen (ls_diretorio, 'resultado_processamento_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
   end if;
   -- Modificado <Charles> - Fim 
   
   ls_seperador_campo:=chr(9);
   ls_seperador_registro:=chr(13)||chr(10);  /* UNIX 10, DOS 13+10 */
  
   select conteudo into blob_edit
   from documento_conteudo
   where documento_id=ln_seq;

   vlen:=dbms_lob.getlength(blob_edit);
   bytelen := 32000;
   vstart := 1;
   
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   
   if vend=0 then
      dbms_output.put_line('O arquivo não possui um FIM DE LINHA do padrão DOS/WINDOS (char 13 + char 10). Provavelmente é um arquivo no formato UNIX.');
      dbms_output.put_line('O arquivo deve ser convertido.');
   end if;
   
  
   WHILE vstart < vlen 
   LOOP
         vlen2:=vend-vstart+1;

         dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
         ls_linha:=utl_raw.cast_to_varchar2(vtemp);
         registros:=registros+1;
         vend2 := 1;
         vstart2 := 1;
         vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
         i:=1;     
         ultimo_campo:=false;
         WHILE vstart2 < vlen2 or ultimo_campo
         LOOP
               select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
               BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;
               ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
               dados.extend;
               dados(i):=ls_campo;
               vstart2:=vend2+length(ls_seperador_campo);
               if not ultimo_campo then
                  vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
               else
                  ultimo_campo:=false;
               end if;
               if vend2 =0 then
                  ultimo_campo:=true;
                  vend2:=vlen2;
               end if;
               i:=i+1;
         END LOOP;

   --------------------------------------
   -- Início do Processamento da Linha --
   --------------------------------------
   -- dbms_output.put_line(dados(1)||dados(2)||dados(3));
   -- Dados prontos para serem trabalhados
   lb_erro:=false;
         if dados(2)='3' then -- Realizado
           
            -- Para identificar o projeto, identificar por 3 valores
            -- 1. Projeto deve ser da UO 
            -- 2. Atributo 2 deve ter 'YYYY XXXXXX' onde YYYY é o ano do orçamento e XXXXXX são os 6 primeiras posicoes do Centro de Resposabilidade 
            -- 3. Atributo 1 deve ter o sequencial posicao a partir da 7 do Centro de Responsabilidade
            dados(3):=trim(dados(3));
            dados(4):=trim(dados(4));
            dados(6):=trim(dados(6));
            dados(7):=trim(dados(7));
            dados(16):=trim(dados(16));
            dados(8):=dados(3)|| ' '|| trim(dados(8));

            if instr(dados(16),' ')>0 then
               dados(16):=substr(dados(16),1,instr(dados(16),' '));
            end if;
            if to_number(dados(9))=0 then
              dados(9):='1';
            end if;

            begin
             select ci.categoria_item_id into ln_categ
                    from categoria_item_atributo ci
                    where ci.titulo like dados(3)|| ' ' || substr(dados(7),1,9) ||'-%' and
                          ci.atributo_id=2;

              exception when no_data_found then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade não localizado: '||chr(9)||dados(3)||' '|| substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 


            begin
             select u.id into ln_uo from uo u where to_number(substr(u.titulo,5,instr(u.titulo,'-')-6)) = to_number(dados(6));

              exception when no_data_found then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' UO não localizado: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Localizou mais de 1 UO: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 

            begin
--dbms_output.put_line(dados(7)||'-'||ln_categ||'-'||ln_uo);
            select id into ln_proj from projeto p
            where p.uo_id = ln_uo  and
                  exists (select *
                from atributoentidadevalor aev--, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = ln_categ
                         --cia.atributo_id=2 and
                         --substr(cia.Titulo,6,instr(cia.Titulo,'-')-6) = dados(3)|| ' ' || substr(dados(7),1,9) and
                         --aev.categoria_item_atributo_id = cia.categoria_item_id
                         ) and
                   exists (select *
                from atributoentidadevalor aev 
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         nvl(aev.Valor, aev.ValorNumerico)= to_number(substr(dados(7),10)) and
                         aev.atributoid=1);
            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ || chr(9)||' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ ||chr(9)|| ' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
           end; 
              
           if (not lb_erro) then

            select nvl(min(ce.id),0) into ln_ce from custo_entidade ce, custo_receita cr
            where ce.tipo_entidade = 'P' and
                  ce.custo_receita_id = cr.id and
                  ce.entidade_id = ln_proj and
                  cr.titulo like dados(8)||'%'; -- conta contabil
            
            -- Modificado <Charles> Ini
            if ln_ce = 0 then   
                        
              select max(id)
                into ln_cr
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 
               
              if ln_cr > 0 then  
           
                select min(forma_id)
                  into ln_forma
                  from (select *
                          from custo_receita_forma 
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1;
                 
                select min(tipo_id)
                  into ln_tipo
                  from (select *
                          from custo_receita_tipo
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1; 
               
                select custo_entidade_seq.nextval into ln_ce from dual;
                
                insert into custo_entidade (id, tipo_entidade, entidade_id, custo_receita_id, titulo, 
                                            tipo_despesa_id, forma_aquisicao_id)
                       values (ln_ce, 'P', ln_proj, ln_cr, dados(8), ln_tipo, ln_forma);
              end if;
            end if;
            -- Modificado <Charles> Fim
            
            if ln_ce > 0 then
                                          
                  -- Modificado <Charles> Ini
                  ld_lancamento := to_date(dados(16),'DD/MM/YYYY');
                  begin
                    ld_lancamento := to_date('01'||trim(to_char(to_number(dados(4)),'00'))||dados(3), 'ddmmyyyy');
                    -- Coloca no último dia do mês
                    ld_lancamento := add_months(ld_lancamento, 1) - 1;
                  exception
                    when others then
                      ld_lancamento := null;
                  end;
                  --dbms_output.put_line('DEBUG: ' || to_char(ld_lancamento, 'dd/mm/yyyy'));
                  -- Modificado <Charles> Fim
                  
                  select nvl(max(id),0) into ln_cl from custo_lancamento 
                  where custo_entidade_id = ln_ce and
                        tipo = 'R' and
                        situacao = 'V' and
                        trunc(data) = trunc(ld_lancamento);

                  if ln_cl=0 then
                      begin
                        select custo_lancamento_seq.nextval into ln_cl from dual;
                        insert into custo_lancamento (ID, CUSTO_ENTIDADE_ID, TIPO, SITUACAO,
                                                      DATA, 
                                                      VALOR,
                                                      QUANTIDADE, 
                                                      VALOR_UNITARIO, 
                                                      USUARIO_ID, DATA_ALTERACAO)
                            values (ln_cl, ln_ce, 'R', 'V',
                                    ld_lancamento,
                                    to_number(dados(10)), -- valor
                                    to_number(dados(9)), -- quantidade
                                    to_number(dados(10))/to_number(dados(9)), -- valor unitario,
                                    '310', 
                                    sysdate);  -- 
                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Inserido - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     exception
                       when others then
                         lv_mensagem := 'Linha:'||chr(9)||' Erro ao incluir: [' || sqlerrm || ']';
                         dbms_output.put_line(lv_mensagem);
                         SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     end;           
                  else
                  -- dbms_output.put_line('Já existe Custo Lançamento para Lançamento para Conta:'||dados(14)||' Projeto:'|| '???' ||' Data:'||substr(dados(16),1,10)|| ' Linha não importada:'||registros);
                  -- se ja existe, acrescenta
                  begin
                    update custo_lancamento
                       set VALOR=VALOR+to_number(dados(10)),
                           QUANTIDADE=QUANTIDADE+to_number(dados(9)), 
                           VALOR_UNITARIO=(VALOR+to_number(dados(10)))/(QUANTIDADE+to_number(dados(9))), 
                           USUARIO_ID='310',
                           DATA_ALTERACAO=sysdate
                    where custo_entidade_id = ln_ce and
                          tipo = 'R' and
                          situacao = 'V' and
                          trunc(data) = trunc(ld_lancamento);

                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Atualizado - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  exception
                    when others then
                      lv_mensagem := 'Linha:'||chr(9)||' Erro ao atualizar: [' || sqlerrm || ']';
                      dbms_output.put_line(lv_mensagem);
                      SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                  end;
                  end if;
            else
               -- Modificado <Charles>
               lb_erro:=true;
               
               lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||'Não foi localizado Custo Entidade para Conta:'||chr(9)||dados(8)||chr(9)||' Projeto:'||chr(9)||ln_proj;
               dbms_output.put_line(lv_mensagem);
               SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
            end if;
            end if;
         end if;
   
   -- Modificado <Charles> - Ini
   -- Grava registro nao processado no arquivo de output
   if lb_erro then
     SYS.UTL_FILE.put_line(lf_rejeitados, ls_linha);
   end if;
   -- Modificado <Charles> - Fim
   
   --------------------------------------
   -- FIM do Processamento da Linha --
   --------------------------------------
   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

   -- tratamento para linha sem fim de linha
     if vend>vlen or vend=0 then
        vend:=vlen;
     end if;
     
     
   dados:=t_dados();
   END LOOP;
   
 -- Modificado <Charles>
 lv_mensagem := 'Linha: '|| registros;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
 
 SYS.UTL_FILE.fclose(lf_rejeitados);
 SYS.UTL_FILE.fclose(lf_log);
 ln_retorno:=registros;

end p_Importa_Arquivo;

procedure p_Carrega_Arquivo (ls_diretorio varchar2, ls_arquivo varchar2, ln_seq out number, ln_retorno in out number)
AS
 
     v_bfile bfile;
     v_blob blob;
     ln_doc int;
     ln_doc_cont int;
     
    begin

      v_bfile := bfilename(ls_diretorio,ls_arquivo);
      dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);

select documento_seq.nextval into ln_doc from dual;
select documento_conteudo_seq.nextval into ln_doc_cont from dual;

Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO,
      TIPOENTIDADE,IDENTIDADE,AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
select ln_doc,ls_diretorio||'-'||ls_arquivo||'- Carregado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),
       null,null,null,'I',1,'.txt',null,null,null,null from dual;

insert into documento_conteudo (id, documento_id, versao, conteudo)
values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

DBMS_LOB.CREATETEMPORARY(v_blob,TRUE);

/*      insert into tab_imagem (id,nome,imagem)
      values (1,p_nome_arquivo,empty_blob())
      return imagem into v_blob;*/
      
      dbms_lob.loadfromfile(v_blob,v_bfile,dbms_lob.getlength(v_bfile));
      dbms_lob.fileclose(v_bfile);

update documento_conteudo
set conteudo = v_blob
where id=ln_doc_cont;

      
  commit;
  ln_retorno:=1;
  ln_seq:=ln_doc;
  
 EXCEPTION
  WHEN UTL_FILE.access_denied THEN
   ln_retorno:=-1;
   dbms_output.put_line('Problema de acesso ao arquivo. Abortado');
   return;

  WHEN UTL_FILE.invalid_path THEN
   ln_retorno:=-1;
   dbms_output.put_line('Diretório Inválido. Abortado');
   return;

  WHEN NO_DATA_FOUND THEN
   ln_retorno:=-1;
   dbms_output.put_line('No Data Found. Abortado');
   return;

  WHEN UTL_FILE.READ_ERROR THEN
   ln_retorno:=-1;
   dbms_output.put_line('Falha na Leitura. Abortado');
   return;

  WHEN UTL_FILE.invalid_filename THEN
   ln_retorno:=-1;
   dbms_output.put_line('Nome de Arquivo inválido. Abortado');
   return;

  WHEN UTL_FILE.invalid_filehandle THEN
   ln_retorno:=-1;
   dbms_output.put_line('Nome de Arquivo inválido. Abortado');
   return;

  WHEN others THEN
   ln_retorno:=-1;
   dbms_output.put_line('Erro inesperado. Abortado');
   return;

end p_Carrega_Arquivo;

procedure p_Carga_Inicial_Script(ln_seq number, ln_retorno in out number)
-----------------------------------------
-- ESTA PROC NÂO ESTA SENDO UTILIZADA  --
-----------------------------------------

is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro boolean:=true;
 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
diretorio varchar2(250) :='IMPORTACAO_TRACEGP';
arquivo varchar2(250) :='SCRIPT_GERADO_CARGA_INICIAL.sql' ;

blob_edit1             BLOB; 
blob_edit2             BLOB; 
blob_edit3             BLOB; 
blob_edit4             BLOB; 
blob_edit5             BLOB; 
blob_edit6             BLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
vFILE_SAIDA    SYS.UTL_FILE.FILE_TYPE;

begin
vFILE_SAIDA  := SYS.UTL_FILE.FOPEN( diretorio, arquivo, 'w',32767 );

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);


--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;
array := new Array2D(
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76)
                                  
                     );   

   DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit2,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit3,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit4,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit5,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit6,TRUE);

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS
     if registros=1 then
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'declare');
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   ln_id_proj number;');              
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   ln_id_atr  number;');              
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'begin');
    end if;
--     dbms_output.put_line(dados(21));
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,' ');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT projeto_seq.nextval INTO ln_id_proj FROM dual;');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO PROJETO (ID,TITULO,DESCRICAO,HORASPREVISTAS,HORASREALIZADAS,PRAZOPREVISTO,PRAZOREALIZADO,SITUACAO,SISTEMA,ORDEM,DATAINICIO,DATAFIMORCAMENTO,PORCENTAGEMCONCLUIDA,PERMITETEMPLATE,TIPOPROJETOID,INICIOREALIZADO,DURACAO,TIPORESTRICAO,DATARESTRICAO,ATUALIZARHORASPREVISTAS,CPI_MONETARIO,SPI_MONETARIO,ENTIDADE_PAI,CONSIDERAR_CUSTO,ALTERAR_PERC_CONCLUIDO,PERMITE_CUSTO_APENAS_TAREFA,EDICAO_EXCLUSIVA,MODIFICADOR,MOTIVO,DASHBOARD_ID,UO_ID,PROJETO_TEMPLATE_ID)');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'      SELECT ln_id_proj,'''|| dados(2)|| ' - ' || dados(3)|| ''',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,''A'',''N'',''Y'',null,''310'',null,null,null,null FROM dual;');

     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'      select ''P'', nvl((select u.usuarioid from usuario u where upper(nome) = upper('''|| dados(4)|| ''')),''310''), ln_id_proj from dual;');

         for x in 1..array.Count
         loop
             if array(x)(2) in(73) then  -- DATA
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;');
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALORDATA)');
                   ls_campo:='      SELECT ln_id_atr, ''P'', ln_id_proj, ' || array(x)(2) ||',to_date('''|| dados(array(x)(1)) || ''',''DD/MM/YYYY'') FROM dual;';
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,ls_campo);
                 end if;
             else -- TEXTO
             if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;');
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)');
               ls_campo:='      SELECT ln_id_atr, ''P'', ln_id_proj, ' || array(x)(2) ||','''|| trim(dados(array(x)(1))) || ''' FROM dual;';
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,ls_campo);
             end if;
             end if;
         end loop;
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   -- Escopo');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)');
--     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ESCOPO (Projeto) values (' || ln_id_proj || ');');

--   if (nvl(trim(dados(8)),'-1') <> '-1') then
--   end if;

/*
    b_int:=utl_raw.length (utl_raw.cast_to_raw(dados(8)));
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,trim(ls_tipo)||'-'||to_char(ln_ano)||' Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

 dbms_lob.FREETEMPORARY(blob_edit);

*/
   end if;
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;
SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'end;');
SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'--Linha:'||registros);
SYS.UTL_FILE.FFLUSH(vFILE_SAIDA);
SYS.UTL_FILE.FCLOSE(vFILE_SAIDA);

ln_retorno:=registros;

end p_Carga_Inicial_Script;

procedure p_Carga_Inicial(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_tar number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS

       
       SELECT projeto_seq.nextval INTO ln_id_proj FROM dual;
       IF primeiro_registro1 THEN
         dbms_output.put_line('SELECT * FROM PROJETO WHERE ID >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM RESPONSAVELENTIDADE WHERE IDENTIDADE >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM ATRIBUTOENTIDADEVALOR WHERE IDENTIDADE >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM ESCOPO WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM PRODUTOENTREGAVEL WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM PREMISSA WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM RESTRICAO WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM OCORRENCIA_ENTIDADE WHERE ENTIDADE_ID >= '||ln_id_proj);
         
         primeiro_registro1:=FALSE;
       END IF;

       INSERT INTO PROJETO (ID,TITULO,DESCRICAO,HORASPREVISTAS,HORASREALIZADAS,PRAZOPREVISTO,PRAZOREALIZADO,SITUACAO,SISTEMA,ORDEM,DATAINICIO,DATAFIMORCAMENTO,PORCENTAGEMCONCLUIDA,PERMITETEMPLATE,TIPOPROJETOID,INICIOREALIZADO,DURACAO,TIPORESTRICAO,DATARESTRICAO,ATUALIZARHORASPREVISTAS,CPI_MONETARIO,SPI_MONETARIO,ENTIDADE_PAI,CONSIDERAR_CUSTO,ALTERAR_PERC_CONCLUIDO,PERMITE_CUSTO_APENAS_TAREFA,EDICAO_EXCLUSIVA,MODIFICADOR,MOTIVO,DASHBOARD_ID,UO_ID,PROJETO_TEMPLATE_ID)
             SELECT ln_id_proj, dados(2)|| ' - ' || dados(3),dados(12),null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'A','N','Y',null,'310',null,null,null,null FROM dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'P', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), ln_id_proj from dual;

       if (nvl(trim(dados(16)),'-1') <> '-1') then

            if length(trim(dados(16)))>4000 then
              dbms_output.put_line('Trunc Ocorrencia Proj:'||ln_id_proj||'  (4000) - Tamanho:' || length(trim(dados(16))));
              dados(16) := substr(trim(dados(16)),1,3997) || '...' ;
            end if;

          SELECT ocorrencia_entidade_seq.nextval INTO ln_id_atr FROM dual;
          INSERT INTO OCORRENCIA_ENTIDADE (ASSUNTO,DATA,ENTIDADE_ID,
                                           NOTIFICAR,OCORRENCIA_ID,USUARIO,
                                           BASE_CONHECIMENTO_ID,TIPO_ENTIDADE,TIPO_OCORRENCIA_ID)
                 select dados(16),null,ln_id_proj,
                        null,ln_id_atr,null,
                        null,'P',null  
                      from dual;
        
       end if;

/*
       if (nvl(trim(dados(17)),'-1') <> '-1') then
          dbms_output.put_line('EQUIPE:'||trim(dados(17)));
       end if;
       if (nvl(trim(dados(11)),'-1') <> '-1') then
          dbms_output.put_line('CR:'||trim(dados(11)));
       end if;*/

         for x in 1..array.Count
         loop
             if array(x)(2) in(73) then  -- DATA
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALORDATA)
                     SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2) ,to_date(dados(array(x)(1)) ,'DD/MM/YYYY') FROM dual;
                 end if;
             elsif  array(x)(2) in(2) then  -- Centro de Responsabilidade
                ln_categ:=0;
                begin
                select categoria_item_id into ln_categ from categoria_item_atributo where titulo like '2010%'||dados(array(x)(1))||'-%' and atributo_id=array(x)(2);

                   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,Categoria_Item_Atributo_Id)
                     SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2), ln_categ FROM dual;

                exception when no_data_found then
                  ln_categ:=0;
                    dbms_output.put_line('Projeto:'||ln_id_proj||'  Atributo Centro Responsabilidade não localizado: '||dados(array(x)(1)) );
                  when others then
                  ln_categ:=0;
                    dbms_output.put_line('Projeto:'||ln_id_proj||'  Atributo Centro Responsabilidade localizou mais de 1 CR: '||dados(array(x)(1)) );
                end; 
               
             
             else -- TEXTO
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                      if length(trim(dados(array(x)(1))))>4000 then
                        dbms_output.put_line('Trunc Projeto:'||ln_id_proj||'  Atributo (4000) '||array(x)(2) || ' - Tamanho:' || length(trim(dados(array(x)(1)))));
                        dados(array(x)(1)) := substr(trim(dados(array(x)(1))),1,3997) || '...' ;
                      end if;
                      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                          SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2), trim(dados(array(x)(1))) FROM dual;
                 end if;
             end if;
         end loop;

      if (nvl(trim(dados(8)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from produtoentregavel;
          insert into produtoentregavel (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(8));  
          
      end if;
   end if;
   if dados(1)='20' then -- Escopo

      INSERT INTO ESCOPO (PROJETO, FECHADO, DESCPRODUTO,JUSTIFICATIVAPROJETO,OBJETIVOSPROJETO,LIMITESPROJETO,LISTAFATORESESSENCIAIS) 
         select ln_id_proj, 'S', empty_clob(), empty_clob(), empty_clob(), empty_clob(), empty_clob() from dual;

      if (nvl(trim(dados(2)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(2));
          dbms_lob.write(blob_edit1, b_int, 1, dados(2));
          update escopo 
            set DESCPRODUTO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(3)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(3));
          dbms_lob.write(blob_edit1, b_int, 1, dados(3));
          update escopo 
            set JUSTIFICATIVAPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(4)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(4));
          dbms_lob.write(blob_edit1, b_int, 1, dados(4));
          update escopo 
            set OBJETIVOSPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(5)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(5));
          dbms_lob.write(blob_edit1, b_int, 1, dados(5));
          update escopo 
            set LIMITESPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;

      if (nvl(trim(dados(6)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from premissa;

          insert into premissa (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(6));

      end if;

      if (nvl(trim(dados(7)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from restricao;

          insert into restricao (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(7));

      end if;
   end if;

   if dados(1)='30' then -- INICIO Atividades

      SELECT atividade_seq.nextval INTO ln_id_ativ FROM dual;
       IF primeiro_registro2 THEN
         dbms_output.put_line('SELECT * FROM ATIVIDADE WHERE ID >= '||ln_id_ativ);
         primeiro_registro2:=FALSE;
       END IF;
/*
      dbms_output.put_line('D5:'||trim(dados(5)));
      dbms_output.put_line('D6:'||trim(dados(6)));
      dbms_output.put_line('D7:'||trim(dados(7)));
      dbms_output.put_line('D8:'||trim(dados(8)));
*/
      if length(trim(dados(2)))>150 then
        dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Titulo (150) - Tamanho:' || length(trim(dados(2))));
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      INSERT INTO ATIVIDADE (ID, TITULO, MODIFICADOR, 
                  DESCRICAO,
                  datainicio,
                  prazoprevisto,    
                  iniciorealizado,    
                  prazorealizado,
                  Situacao, Projeto)
             select ln_id_ativ,  dados(2), nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(3))),'310'), 
                    dados(4),
                    trunc(to_date(trim(dados(5)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
                    1,ln_id_proj
                     from dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'A', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(3))),'310'), ln_id_ativ from dual;

       if (nvl(trim(dados(15)),'-1') <> '-1') then  -- Atributo Resultados de Atividades
            if length(trim(dados(15)))>4000 then
              dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Atributo (4000) 77 - Tamanho:' || length(trim(dados(15))));
              dados(15) := substr(trim(dados(15)),1,3997) || '...' ;
            end if;
            SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
            INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                SELECT ln_id_atr, 'A', ln_id_ativ, 77, trim(dados(15)) FROM dual;
       end if;

       if (nvl(trim(dados(16)),'-1') <> '-1') then

            if length(trim(dados(16)))>4000 then
              dbms_output.put_line('Trunc Ocorrencia Ativ:'||ln_id_ativ||'  (4000) - Tamanho:' || length(trim(dados(16))));
              dados(16) := substr(trim(dados(16)),1,3997) || '...' ;
            end if;

          SELECT ocorrencia_entidade_seq.nextval INTO ln_id_atr FROM dual;
          INSERT INTO OCORRENCIA_ENTIDADE (ASSUNTO,DATA,ENTIDADE_ID,
                                           NOTIFICAR,OCORRENCIA_ID,USUARIO,
                                           BASE_CONHECIMENTO_ID,TIPO_ENTIDADE,TIPO_OCORRENCIA_ID)
                 select dados(16),null,ln_id_proj,
                        null,ln_id_atr,null,
                        null,'P',null  
                      from dual;
        
       end if;

       if (nvl(trim(dados(17)),'-1') <> '-1') then  -- Atributo Recomendações
            if length(trim(dados(17)))>4000 then
              dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Atributo (4000) 78 - Tamanho:' || length(trim(dados(17))));
              dados(17) := substr(trim(dados(17)),1,3997) || '...' ;
            end if;
            SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
            INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                SELECT ln_id_atr, 'A', ln_id_ativ, 78, trim(dados(17)) FROM dual;
       end if;

       if (nvl(trim(dados(12)),'-1') <> '-1') then
          dbms_output.put_line('TIPO:'||trim(dados(12)));
       end if;
       if (nvl(trim(dados(13)),'-1') <> '-1') then
          dbms_output.put_line('PREDECES:'||trim(dados(13)));
       end if;

   end if;  -- FIM Atividades

   if dados(1)='40' then -- INICIO Tarefas

      SELECT tarefa_seq.nextval INTO ln_id_tar FROM dual;
       IF primeiro_registro3 THEN
         dbms_output.put_line('SELECT * FROM TAREFA WHERE ID >= '||ln_id_tar);
         primeiro_registro3:=FALSE;
       END IF;

--      dbms_output.put_line('Tit ini hor:'||dados(2) ||'-' || trim(dados(6))||'-' || trim(dados(10)));

      
      if length(trim(dados(2)))>150 then
        dbms_output.put_line('Trunc TAREFA:'||ln_id_tar||'  Titulo (150) - Tamanho:' || length(trim(dados(2))));
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      INSERT INTO TAREFA (ID, TITULO, MODIFICADOR, 
                  DESCRICAO,
                  datainicio,
                  prazoprevisto,    
                  iniciorealizado,    
                  prazorealizado,
                  Atividade,
                  horasprevistas,
                  horasrealizadas,
                  situacao, projeto)
             select ln_id_tar,  dados(2), nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), 
                    dados(5),
                    trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(9)) ,'DD/MM/YYYY HH24:MI:SS')),
                    ln_id_ativ,
                    trim(dados(10)),
                    trim(dados(11)),
                    1,ln_id_proj
                from dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'T', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), ln_id_tar from dual;

   end if;  -- FIM Tarefas

   if dados(1)='50' then -- INICIO Metas

      ls_campo:='Descrição:' || nvl(trim(dados(2)),' ');
      ls_campo:=ls_campo||'Indicador:'|| nvl(trim(dados(3)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Tarefa ou Atividade Vinculada:'|| nvl(trim(dados(4)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Critério (Status ou Acumulado):'|| nvl(trim(dados(5)),' ')  || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Unidade de medida:'|| nvl(trim(dados(6)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Ano:'|| nvl(trim(dados(7)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'mês limite:'|| nvl(trim(dados(8)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Previsto:'|| nvl(trim(dados(9)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Retificado:'|| nvl(trim(dados(10)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Revisado:'|| nvl(trim(dados(11)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Realizado:'|| nvl(trim(dados(12)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Observações:'|| nvl(trim(dados(13)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'% de desempenho:'|| nvl(trim(dados(14)),' ') || CHR(13) || CHR(10);

      if length(ls_campo)>4000 then
        dbms_output.put_line('Trunc Metas do Projeto:'||ln_id_proj||'  Atributo (4000) 79 - Tamanho:' || length(ls_campo));
        ls_campo := substr(trim(ls_campo),1,3997) || '...' ;
      end if;
      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
          SELECT ln_id_atr, 'P', ln_id_proj, 79, trim(ls_campo) FROM dual;

   end if;  -- FIM Metas

   if dados(1) in ('60','90') then -- INICIO Despesas / Receitas
      ln_categ:=0;
      lb_erro:=false;
      
      if dados(1)='60' then 
         ls_tipo:='C';
      else
         ls_tipo:='R';
      end if;
      begin
        
         select ID into ln_categ
           from custo_receita where trim(Titulo) like trim(dados(2)) || ' %' || trim(dados(3))|| '% - %' and tipo=ls_tipo;-- and vigente = 'Y';
      exception
         when no_data_found then
         dbms_output.put_line('Projeto:'||ln_id_proj ||' Não localizou na Árvore de custos:'||trim(dados(2)) || ' - ' || trim(dados(3))|| ' Tipo:'||ls_tipo);
         lb_erro:=true;
         when others then
         dbms_output.put_line('Projeto:'||ln_id_proj ||' Árvore de custos com mais de 1 registro para:'||trim(dados(2)) || ' - ' || trim(dados(3))|| ' Tipo:'||ls_tipo);
         lb_erro:=true;
      end;
      
      if not lb_erro then

      -- inclui permissoes automaticas para inclusão de lançamento
      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_forma crf
        where crf.forma_id         = case ls_tipo when 'C' then 7 else 8 end
          and crf.vigente          = 'Y'
          and crf.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_forma_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro6 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_FORMA WHERE ID >= '||ln_tipo);
           primeiro_registro6:=FALSE;
         END IF;

         insert into custo_receita_forma (ID,CUSTO_RECEITA_ID,FORMA_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 7 else 8 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_tipo crt
        where crt.tipo_id          = case ls_tipo when 'C' then 3 else 4 end
          and crt.vigente          = 'Y'
          and crt.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_tipo_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro7 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_TIPO WHERE ID >= '||ln_tipo);
           primeiro_registro7:=FALSE;
         END IF;

         insert into custo_receita_tipo (ID,CUSTO_RECEITA_ID,TIPO_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 3 else 4 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;
        
      ln_id_atr:=0;
        
      select nvl(min(id),0) into ln_id_atr
      from custo_entidade 
        where TIPO_ENTIDADE='P' and
              ENTIDADE_ID=ln_id_proj and
              CUSTO_RECEITA_ID=ln_categ;


      if ln_id_atr=0 then

        SELECT custo_entidade_seq.nextval INTO ln_id_atr FROM dual;

         IF primeiro_registro4 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_ENTIDADE WHERE ID >= '||ln_id_atr);
           primeiro_registro4:=FALSE;
         END IF;

        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'P',ln_id_proj,ln_categ,
                  trim(dados(3)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;

      end if;
      

 
      -- R Realizado
      if (nvl(trim(dados(8)),'-1') <> '-1') and to_number(dados(8))>0 then

         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_tar);
           primeiro_registro5:=FALSE;
         END IF;

         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'R','V',  -- realizado, válido
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(8)),1,to_number(dados(8)),'310',
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
           
      end if;

      -- P Planejado
      if (nvl(trim(dados(5)),'-1') <> '-1') and to_number(dados(5))>0 then
         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_atr);
           primeiro_registro5:=FALSE;
         END IF;
         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'P','V',  -- realizado, válido
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(5)),1,to_number(dados(5)),'310',
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
           
      end if;

      -- P Retificado
      if (nvl(trim(dados(6)),'-1') <> '-1') and to_number(dados(6))>0 then
        update custo_entidade
        set Motivo = nvl(Motivo,' ') || ' Refificado:' ||trim(dados(6))
        where id=ln_id_atr;
      end if;

      -- P Revisado
      if (nvl(trim(dados(7)),'-1') <> '-1') and to_number(dados(7))>0 then
        update custo_entidade
        set Motivo = nvl(Motivo,' ') || ' Revisado:' ||trim(dados(7))
        where id=ln_id_atr;
      end if;


      end if;
   end if;  -- FIM Despesas
 
   if dados(1) in ('80') then -- Origem dos recursos

         for x in 1..array2.Count
         loop
                 if (nvl(trim(dados(array2(x)(1))),'-1') <> '-1') then
                      if length(trim(dados(array2(x)(1))))>4000 then
                        dbms_output.put_line('Trunc Projeto:'||ln_id_proj||'  Atributo (4000) '||array2(x)(2) || ' - Tamanho:' || length(trim(dados(array2(x)(1)))));
                        dados(array2(x)(1)) := substr(trim(dados(array2(x)(1))),1,3997) || '...' ;
                      end if;
                      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                          SELECT ln_id_atr, 'P', ln_id_proj, array2(x)(2), trim(dados(array2(x)(1))) FROM dual;
                 end if;
         end loop;
   end if; -- FIM Origem dos recursos

  delete contadores where nometabela in ('RESTRICAO', 'PREMISSA', 'PRODUTOENTREGAVEL');
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Carga_Inicial;          

procedure p_Importa_Custos(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_ativc number:=0;
ln_id_tar number:=0;              
ln_id_tarc number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
--ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

    lb_erro:=false;
    ln_id_proj:=0;
    ls_tipo:='C';

--dados(4):='2010 390010101';

     begin       
      
     dados(1):='2010 '||dados(1);
--     dados(1):='2010 1900101043504';

     select ci.categoria_item_id into ln_categ
            from categoria_item_atributo ci
            where ci.titulo like dados(1)||'%';

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Atributo Centro Responsabilidade não localizado: '||dados(1) );
          lb_erro:=true;
        when others then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||dados(1) );
          lb_erro:=true;
     end; 
            
     
    if not lb_erro then
     begin
     select Identidade into ln_id_proj 
          from ATRIBUTOENTIDADEVALOR 
              where      TIPOENTIDADE='P' and
                         ATRIBUTOID = 2 and 
                         Categoria_Item_Atributo_Id = ln_categ;
      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||dados(1) );
          lb_erro:=true;
        when others then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||dados(1) );
          lb_erro:=true;
     end; 
    end if;
    if not lb_erro then
--        dbms_output.put_line('Custo:'|| trim(dados(4))||' Proj:'|| ln_id_proj);
        ln_categ:=0;
        begin
           select ID into ln_categ
             from custo_receita where trim(Titulo) like trim(dados(4))|| '% - %' and tipo=ls_tipo;-- and vigente = 'Y';
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não localizou na Árvore de custos:'|| trim(dados(4))|| ' Tipo:'||ls_tipo);
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Árvore de custos com mais de 1 registro para:'|| trim(dados(4))|| ' Tipo:'||ls_tipo);
           lb_erro:=true;
        end;

      if not lb_erro then
      -- inclui permissoes automaticas para inclusão de lançamento
      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_forma crf
        where crf.forma_id         = case ls_tipo when 'C' then 7 else 8 end
          and crf.vigente          = 'Y'
          and crf.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_forma_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro6 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_FORMA WHERE ID >= '||ln_tipo);
           primeiro_registro6:=FALSE;
         END IF;

         insert into custo_receita_forma (ID,CUSTO_RECEITA_ID,FORMA_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 7 else 8 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_tipo crt
        where crt.tipo_id          = case ls_tipo when 'C' then 3 else 4 end
          and crt.vigente          = 'Y'
          and crt.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_tipo_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro7 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_TIPO WHERE ID >= '||ln_tipo);
           primeiro_registro7:=FALSE;
         END IF;

         insert into custo_receita_tipo (ID,CUSTO_RECEITA_ID,TIPO_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 3 else 4 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_tarc:=0;
      begin
        select id into ln_id_tarc
        from tarefa
          where projeto=ln_id_proj and
                trim(tarefa.titulo)=trim(dados(3));
--           dbms_output.put_line('Achou Tarefa');
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não Achou Tarefa:'||trim(dados(3)));
           ln_id_tarc:=0;
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||'Achou Mais de uma Tarefa:'||trim(dados(3)));
           ln_id_tarc:=0;
           lb_erro:=true;
      end;
      ln_id_ativc:=0;

      if ln_id_tarc=0 then
      begin
        select id into ln_id_ativc
        from atividade
          where projeto=ln_id_proj and
                trim(titulo)=trim(dados(3));
           dbms_output.put_line('Achou Atividade');
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não Achou Atividade:'||trim(dados(3)));
           ln_id_ativc:=0;
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||'Achou Mais de uma Atividade:'||trim(dados(3)));
           ln_id_ativc:=0;
           lb_erro:=true;
      end;
        
      
      end if;
              
      ln_id_atr:=0;

      if ln_id_tarc>0 then

          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='T' and
                  ENTIDADE_ID=ln_id_tarc and
                  CUSTO_RECEITA_ID=ln_categ;

      elsif ln_id_ativc>0 then

          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='A' and
                  ENTIDADE_ID=ln_id_ativc and
                  CUSTO_RECEITA_ID=ln_categ;

      else
          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='P' and
                  ENTIDADE_ID=ln_id_proj and
                  CUSTO_RECEITA_ID=ln_categ;
      end if;


      if ln_id_atr=0 then

        SELECT custo_entidade_seq.nextval INTO ln_id_atr FROM dual;

         IF primeiro_registro4 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_ENTIDADE WHERE ID >= '||ln_id_atr);
           primeiro_registro4:=FALSE;
         END IF;

      if ln_id_tarc>0 then
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'T',ln_id_tarc,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
      elsif ln_id_ativc>0 then
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'A',ln_id_ativc,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
      
      else
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'P',ln_id_proj,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
        
      end if;

      end if;
      
      -- P Planejado
      if (nvl(trim(dados(7)),'-1') <> '-1') and to_number(dados(7))>0 then
         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_tar);
           primeiro_registro5:=FALSE;
         END IF;
         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'P','V',  -- planejado, válido
                  trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(7)),1,to_number(dados(7)),'310',sysdate
--                  trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
      end if;
      end if;

        
    end if;



 
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Importa_Custos;

procedure p_Acerto_Carga_Inicial(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_tar number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
lb_erro_ativ  boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS

      lb_erro:=false;
      lb_erro_ativ:=false;
      
      begin

      select id into ln_id_proj from projeto
      where Titulo = dados(2)|| ' - ' || dados(3) and
           id >= (select id from projeto where titulo in ('PJ-NAC 1011 - Programa SENAI de Ações Inclusivas')) and
           id <= (select id from projeto where titulo in ('PJ-NAC 1028 - Apoio a estruturação de programa de capacitação de RH em normalização - 2010')) and
           exists (select * from ATRIBUTOENTIDADEVALOR a, categoria_item_atributo c
                      where c.atributo_id = 2 and
                            a.identidade = projeto.id and
                            a.tipoentidade = 'P' and
                            a.atributoid = 2 and
                            c.titulo like '2010%'||dados(11)||'-%' and
                            c.categoria_item_id = a.categoria_item_atributo_id);
                            
      dbms_output.put_line('   Projeto:'||ln_id_proj||' ('||dados(2)|| ' - ' || dados(3)||')');

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou projeto: '||dados(2)|| ' - ' || dados(3) || ' CR:'||dados(11));
          lb_erro:=true;
          ln_id_proj:=0;
        when others then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de um projeto: '||dados(2)|| ' - ' || dados(3)  || ' CR:'||dados(11));
          lb_erro:=true;
          ln_id_proj:=0;
     end; 

   end if;

   if (dados(1)='30' and not lb_erro and ln_id_proj>0 ) then -- INICIO Ativ
      lb_erro_ativ:=false;
      if length(trim(dados(2)))>150 then
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;
      begin
      ln_id_ativ:=0;
      select id into ln_id_ativ from atividade
      where Titulo like trim(dados(2))||'%' and
            projeto =ln_id_proj;
      exception when no_data_found then
      ln_id_ativ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou Atividade: '||dados(2)|| ' - ' || dados(3) || ' CR:'||dados(11));
          lb_erro_ativ:=true;
          ln_id_proj:=0;
        when others then
          ln_id_ativ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de uma Atividade: '||dados(2)|| ' - ' || dados(3)  || ' CR:'||dados(11));
          lb_erro_ativ:=true;
          ln_id_proj:=0;
     end; 
   
   end if;

   if (dados(1)='40' and not lb_erro and not lb_erro_ativ and ln_id_proj>0 ) then -- INICIO Tarefas

      
      if length(trim(dados(2)))>150 then
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      begin

      select id into ln_id_tar from tarefa
      where Titulo = dados(2) and
            tarefa.atividade = ln_id_ativ and
            projeto =ln_id_proj;

      update tarefa set
         datainicio=trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
         prazoprevisto=trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
         iniciorealizado=trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
         prazorealizado=trunc(to_date(trim(dados(9)) ,'DD/MM/YYYY HH24:MI:SS')),
         tiporestricao=2, 
         datarestricao=trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS'))
      where id=ln_id_tar;

      dbms_output.put_line('      Tarefa:'||ln_id_tar|| ' (' ||dados(2) ||') Atualizada!'  );

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou tarefa: '||dados(2) );
        when others then
        ln_categ:=0;
          
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de uma tarefa: '||dados(2) ||' msg: '|| sqlerrm);
     end; 

   end if;  -- FIM Tarefas

 
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Acerto_Carga_Inicial;          

procedure p_Importa_View_Zeus(ls_diretorio varchar2, ln_retorno in out number)
is
 ls_campo              VARCHAR2(1000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(2000);
 vtemp                 RAW(32000);
 vend                  NUMBER := 1;
 vlen                  NUMBER := 1;
 vstart                NUMBER := 1;
 vend2                 NUMBER := 1;
 vlen2                 NUMBER := 1;
 vstart2               NUMBER := 1;
 i                     number;
 ln_proj               number:=0;
 bytelen               NUMBER := 32000;
 ultimo_campo          boolean;
 registros             number:=0;     
 ln_ce                 number:=0;
 ln_cl                 number:=0;
 TYPE t_dados IS VARRAY(100) OF varchar2(32000);
 dados t_dados:=t_dados();
 lb_erro boolean:=false;
 ln_categ number;
 ln_uo number;
 -- Modificado <Charles> Ini
 lf_rejeitados SYS.UTL_FILE.file_type;
 lf_log        SYS.UTL_FILE.file_type;
 ln_forma      number := 0;
 ln_tipo       number := 0;
 ln_cr         number := 0;
 ld_lancamento date;
 lv_mensagem   varchar2(4000);
 ld_data_hora  date;
 -- Modificado <Charles> Fim
 v_blob blob;
 ln_inseridos number:=0;
 ln_sinal number:=1;
 
begin
   dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));
  
   -- Modificado <Charles> - Ini  
   if ls_diretorio is not null then
     select sysdate into ld_data_hora from dual;
     lf_rejeitados := SYS.UTL_FILE.fopen (ls_diretorio, 'registros_rejeitados_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
     lf_log        := SYS.UTL_FILE.fopen (ls_diretorio, 'resultado_processamento_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
   end if;
   -- Modificado <Charles> - Fim 
   
   ls_seperador_campo:=chr(9);
   ls_seperador_registro:=chr(13)||chr(10);

   for c in (
        select 
        UNIDADE_COD,  MIN(ANO) ANO, MIN(DATA_FECHTO) DATA_FECHTO
        from VW_TRACEGP_ZEUS d
/*        where exists
          (select p.id from projeto p, atributoentidadevalor aev, categoria_item_atributo cia, atributoentidadevalor aev2, uo u
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id and
                         cia.titulo like trim(to_char(d.ano))||' '||trim(substr(cr_cod,1,9))||'-%' and
                         
                         p.uo_id=u.id and
                         u.titulo like trim(to_char(d.ano))||trim(d.unidade_cod)||'%' and

                         aev2.identidade = p.id and 
                         aev2.tipoentidade='P' and 
                         aev2.atributoid=1 and
                         aev2.valornumerico=to_number(substr(cr_cod,10)))
  */      
        group by UNIDADE_COD
        )
   loop

----------------------------------------------------------
-- falta                                                --
----------------------------------------------------------
--falta filtrar o UO
--falta ver a questado do > ou >=  DT_FECHAMENTO
--falta analisar a questao do Débito - Credito
--falta descricao do lançamento (ficará em campo novo)
----------------------------------------------------------
--                                                      --
----------------------------------------------------------

        delete from baseline_custo_lancamento cl
        where cl.custo_lancamento_id in
        (select cl2.id from custo_lancamento cl2
         where cl2.tipo = 'R'
           and data > c.DATA_FECHTO
           and exists (select 1
                         from custo_entidade ce, projeto p, uo u
                        where ce.id = cl2.custo_entidade_id
                          and p.id = ce.entidade_id
                          and ce.tipo_entidade = 'P'
                          and p.uo_id = u.id and
                          u.titulo like trim(to_char(c.ano))||trim(c.unidade_cod)||'%'));
                          
        delete from custo_lancamento cl
         where cl.tipo = 'R'
           and data > c.DATA_FECHTO
           and exists (select 1
                         from custo_entidade ce, projeto p, uo u
                        where ce.id = cl.custo_entidade_id
                          and p.id = ce.entidade_id
                          and ce.tipo_entidade = 'P'
                          and p.uo_id = u.id and
                          u.titulo like trim(to_char(c.ano))||trim(c.unidade_cod)||'%');

        delete from baseline_custo_entidade ce
         where not exists (select 1 
                             from baseline_custo_lancamento cl
                            where cl.baseline_custo_entidade_id = ce.id);
         
        delete from custo_entidade ce
         where not exists (select 1 
                             from custo_lancamento cl
                            where cl.custo_entidade_id = ce.id);
   end loop;

   dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

   -- SALVA DADOS da VIEW em BLOB --

  select documento_seq.nextval into ln_doc from dual;
  select documento_conteudo_seq.nextval into ln_doc_cont from dual;

  Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO,
        TIPOENTIDADE,IDENTIDADE,AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
  select ln_doc,'View Carregada em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),
         null,null,null,'I',1,'.txt',null,null,null,null from dual;

  insert into documento_conteudo (id, documento_id, versao, conteudo)
  values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

  DBMS_LOB.CREATETEMPORARY(v_blob,TRUE);


  ls_linha:='DATA_LANCTO'||  ls_seperador_campo ||'ANO'||  ls_seperador_campo ||'UNIDADE_COD'||  ls_seperador_campo ||'CR_COD'||  ls_seperador_campo ||'CONTA_COD'||  ls_seperador_campo ||'VALOR'||  ls_seperador_campo ||'DESCRICAO'||  ls_seperador_campo ||'DEB_CRED'||  ls_seperador_campo ||'DATA_FECHTO'||ls_seperador_registro;
  b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
  dbms_lob.write(v_blob, b_int, 1, utl_raw.cast_to_raw(ls_linha));

  dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

   for c in (
       select 
        DATA_LANCTO, ANO, MES, EMPRESA_COD, UNIDADE_COD, 
        CR_COD,  CONTA_COD, CONTA_COD_CTB,  VALOR,  
        DESCRICAO, DEB_CRED, DATA_FECHTO
        from VW_TRACEGP_ZEUS d
/*        where exists
          (select p.id from projeto p, atributoentidadevalor aev, categoria_item_atributo cia, atributoentidadevalor aev2, uo u
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id and
                         cia.titulo like trim(to_char(d.ano))||' '||trim(substr(cr_cod,1,9))||'-%' and
                         
                         p.uo_id=u.id and
                         u.titulo like trim(to_char(d.ano))||trim(d.unidade_cod)||'%' and

                         aev2.identidade = p.id and 
                         aev2.tipoentidade='P' and 
                         aev2.atributoid=1 and
                         aev2.valornumerico=to_number(substr(cr_cod,10)))
*/

/* dados de teste
       select 
        sysdate+level DATA_LANCTO, 2010  ANO, 6  MES, 3  EMPRESA_COD, '100'  UNIDADE_COD, 
        '10102010102'  CR_COD,  '31010314' CONTA_COD, '31010314'  CONTA_COD_CTB,  17.74*level VALOR,  
        'Importado do Sistema de Almoxarifado' DESCRICAO, case when level<10 then 'C' else 'D' end DEB_CRED, sysdate-1   DATA_FECHTO
        from dual CONNECT BY level <= 20 */
     )
   loop

    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados(2):='3';
    dados(3):=to_char(c.ano);
    dados(6):=trim(to_char(c.ano))||trim(c.unidade_cod);
    dados(7):=trim(c.cr_cod);
    dados(8):=trim(c.conta_cod);
    dados(9):='1';
    dados(10):=trim(c.valor);
    dados(16):=to_char(c.DATA_LANCTO,'DD/MM/YYYY');
    dados(12):=trim(c.DESCRICAO);
    dados(17):=trim(c.DEB_CRED);
    dados(18):=to_char(c.DATA_FECHTO,'DD/MM/YYYY');

    ls_linha:= dados(16) || ls_seperador_campo || 
            dados(3) ||  ls_seperador_campo ||
            dados(6) ||  ls_seperador_campo ||
            dados(7) ||  ls_seperador_campo ||
            dados(8) ||  ls_seperador_campo ||
            dados(10) || ls_seperador_campo ||
            dados(12) || ls_seperador_campo ||
            dados(17) || ls_seperador_campo ||
            dados(18) || ls_seperador_registro;

   registros:=registros+1;
   --------------------------------------
   -- Início do Processamento da Linha --
   --------------------------------------
   -- dbms_output.put_line(dados(1)||dados(2)||dados(3));
   -- Dados prontos para serem trabalhados
   lb_erro:=false;
         if dados(2)='3' then -- Realizado
           
            -- Para identificar o projeto, identificar por 3 valores
            -- 1. Projeto deve ser da UO 
            -- 2. Atributo 2 deve ter 'YYYY XXXXXX' onde YYYY é o ano do orçamento e XXXXXX são os 6 primeiras posicoes do Centro de Resposabilidade 
            -- 3. Atributo 1 deve ter o sequencial posicao a partir da 7 do Centro de Responsabilidade

            dados(3):=trim(dados(3));
            dados(4):=trim(dados(4));
            dados(6):=trim(dados(6));
            dados(7):=trim(dados(7));
            dados(16):=trim(dados(16));
            dados(8):=dados(3)|| ' '|| trim(dados(8));

            if to_number(dados(9))=0 then
              dados(9):='1';
            end if;

            begin
             select ci.categoria_item_id into ln_categ
                    from categoria_item_atributo ci
                    where ci.titulo like dados(3)|| ' ' || substr(dados(7),1,9) ||'-%' and
                          ci.atributo_id=2;

              exception when no_data_found then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade não localizado: '||chr(9)||dados(3)||' '|| substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 


            begin
             select u.id into ln_uo from uo u where u.titulo like dados(6)||'%';

              exception when no_data_found then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' UO não localizado: '||chr(9)||dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Localizou mais de 1 UO: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 

           if (not lb_erro) then
            begin
--dbms_output.put_line(dados(7)||'-'||ln_categ||'-'||ln_uo);
            select id into ln_proj from projeto p
            where p.uo_id = ln_uo  and
                  exists (select *
                from atributoentidadevalor aev--, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = ln_categ
                         --cia.atributo_id=2 and
                         --substr(cia.Titulo,6,instr(cia.Titulo,'-')-6) = dados(3)|| ' ' || substr(dados(7),1,9) and
                         --aev.categoria_item_atributo_id = cia.categoria_item_id
                         ) and
                   exists (select *
                from atributoentidadevalor aev 
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         nvl(aev.Valor, aev.ValorNumerico)= to_number(substr(dados(7),10)) and
                         aev.atributoid=1);
            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ || chr(9)||' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ ||chr(9)|| ' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
           end; 
           end if;
           
           if (not lb_erro) then

            select nvl(min(ce.id),0) into ln_ce from custo_entidade ce, custo_receita cr
            where ce.tipo_entidade = 'P' and
                  ce.custo_receita_id = cr.id and
                  ce.entidade_id = ln_proj and
                  cr.titulo like dados(8)||'%'; -- conta contabil
            
            -- Modificado <Charles> Ini
            if ln_ce = 0 then   

/*
Se DEB_CRED = D e conta de despesa (3) = sinal POSITIVO antes do valor 
Se DEB_CRED = C e conta de despesa (3) = sinal NEGATIVO antes do valor 
Se DEB_CRED = D e conta de receita (4) = sinal NEGATIVO antes do valor 
Se DEB_CRED = C e conta de receita (4) = sinal POSITIVO antes do valor 
*/
                        
             begin
              select id,       case when tipo='D' and dados(17)='C' then -1
                                    when tipo='R' and dados(17)='D' then -1
                                    else 1 end
                into ln_cr, ln_sinal
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 

            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Conta Custo Receita: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Erro. A Conta Custo Receita deve ser única: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
             end;
               
              if ln_cr > 0 and not lb_erro then  
           
                select min(forma_id)
                  into ln_forma
                  from (select *
                          from custo_receita_forma 
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1;
                 
                select min(tipo_id)
                  into ln_tipo
                  from (select *
                          from custo_receita_tipo
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1; 
               
                select custo_entidade_seq.nextval into ln_ce from dual;
                
                insert into custo_entidade (id, tipo_entidade, entidade_id, custo_receita_id, titulo, 
                                            tipo_despesa_id, forma_aquisicao_id)
                       values (ln_ce, 'P', ln_proj, ln_cr, dados(8), ln_tipo, ln_forma);
              end if;
            end if;
            -- Modificado <Charles> Fim
            
            if ln_ce > 0 and not lb_erro then
                                          
                  -- Modificado <Charles> Ini
                  ld_lancamento := to_date(dados(16),'DD/MM/YYYY');
/*                  begin
                    ld_lancamento := to_date('01'||trim(to_char(to_number(dados(4)),'00'))||dados(3), 'ddmmyyyy');
                    -- Coloca no último dia do mês
                    ld_lancamento := add_months(ld_lancamento, 1) - 1;
                  exception
                    when others then
                      ld_lancamento := null;
                  end;*/
                  --dbms_output.put_line('DEBUG: ' || to_char(ld_lancamento, 'dd/mm/yyyy'));
                  -- Modificado <Charles> Fim
/*                  
                  select nvl(max(id),0) into ln_cl from custo_lancamento 
                  where custo_entidade_id = ln_ce and
                        tipo = 'R' and
                        situacao = 'V' and
                        trunc(data) = trunc(ld_lancamento);

                  if ln_cl=0 then*/
                      begin
                        select custo_lancamento_seq.nextval into ln_cl from dual;
                        insert into custo_lancamento (ID, CUSTO_ENTIDADE_ID, TIPO, SITUACAO,
                                                      DATA, 
                                                      VALOR,
                                                      QUANTIDADE, 
                                                      VALOR_UNITARIO, 
                                                      USUARIO_ID, DATA_ALTERACAO, DESCRICAO)
                            values (ln_cl, ln_ce, 'R', 'V',
                                    ld_lancamento,
                                    to_number(dados(10))*ln_sinal, -- valor
                                    to_number(dados(9)), -- quantidade
                                    (to_number(dados(10))*ln_sinal)/to_number(dados(9)), -- valor unitario,
                                    '310', 
                                    sysdate,
                                    trim(dados(12)));  -- 
                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Inserido - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       ln_inseridos:=ln_inseridos+1;
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     exception
                       when others then
                         lv_mensagem := 'Linha:'||chr(9)||' Erro ao incluir: [' || sqlerrm || ']';
                         dbms_output.put_line(lv_mensagem);
                         SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     end;           
/*
                  else
                  -- dbms_output.put_line('Já existe Custo Lançamento para Lançamento para Conta:'||dados(14)||' Projeto:'|| '???' ||' Data:'||substr(dados(16),1,10)|| ' Linha não importada:'||registros);
                  -- se ja existe, acrescenta
                  begin
                    update custo_lancamento
                       set VALOR=VALOR+to_number(dados(10)),
                           QUANTIDADE=QUANTIDADE+to_number(dados(9)), 
                           VALOR_UNITARIO=(VALOR+to_number(dados(10)))/(QUANTIDADE+to_number(dados(9))), 
                           USUARIO_ID='310',
                           DATA_ALTERACAO=sysdate
                    where custo_entidade_id = ln_ce and
                          tipo = 'R' and
                          situacao = 'V' and
                          trunc(data) = trunc(ld_lancamento);

                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Atualizado - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  exception
                    when others then
                      lv_mensagem := 'Linha:'||chr(9)||' Erro ao atualizar: [' || sqlerrm || ']';
                      dbms_output.put_line(lv_mensagem);
                      SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                  end;
                  end if;*/
            elsif not lb_erro then
               -- Modificado <Charles>
               lb_erro:=true;
               
               lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||'Não foi localizado Custo Entidade para Conta:'||chr(9)||dados(8)||chr(9)||' Projeto:'||chr(9)||ln_proj;
               dbms_output.put_line(lv_mensagem);
               SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
            end if;
            end if;
         end if;
   
   -- Modificado <Charles> - Ini
   -- Grava registro nao processado no arquivo de output
   if lb_erro then
     SYS.UTL_FILE.put_line(lf_rejeitados, ls_linha);
   end if;
   -- Modificado <Charles> - Fim
   
   --------------------------------------
   -- FIM do Processamento da Linha --
   --------------------------------------

   -- SALVA linha de dados da VIEW em BLOB --
    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
    dbms_lob.writeappend(v_blob, b_int , utl_raw.cast_to_raw(ls_linha));

    if mod(registros,10)= 0 then
     commit;
    end if;
     
   dados:=t_dados();
   END LOOP;

  -- salva CLOB no documento
  update documento_conteudo
  set conteudo = v_blob
  where id=ln_doc_cont;
   
 -- Modificado <Charles>
 lv_mensagem := 'Registros Processados: '|| registros;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);

 lv_mensagem := 'Registros Inseridos: '|| ln_inseridos;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);

 
 SYS.UTL_FILE.fclose(lf_rejeitados);
 SYS.UTL_FILE.fclose(lf_log);
 ln_retorno:=registros;
 dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

end p_Importa_View_Zeus;

PROCEDURE p_Exporta_Arquivo_CNI(ls_tipo varchar2, ln_arquivo in out number, ln_retorno in out number) AS

 ls_diretorio  varchar2(100):='IMPORTACAO_TRACEGP';
 ls_campo              VARCHAR2(2000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(32000);
 ld_data_hora          date;
 ln_registros          number:=0;
 
    v_buffer       RAW(32767);
    v_buffer_size  BINARY_INTEGER;
    v_amount       BINARY_INTEGER;
    v_offset       NUMBER(38) := 1;
    v_chunksize    INTEGER;
    v_out_file     UTL_FILE.FILE_TYPE;

begin

--ls_tipo = 'CTB' ou 'DOF'

/*

x=atributo do valor
y1=estado atual
y2=estado novo
z=formulario
w=DATA_PAGAMENTO
v=DATA_Liberacao/vencimento/provisao
a=conta fluxo
b=conta contabil
c=lista de estados: Liberado, gerado, pago

select 'A','I','TRACE','1','Trace',null,
            -- Atributo da Demanda
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data,
            -- Atributo da Demanda
            (select av.valornumerico from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--x
            ) Valor ,
            null,null,null,
            sysdate,
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data2,
            null,null,null,null,null,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--a
            ) Cta_Fluxo ,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--b
            ) Cta_Contabil ,
            'UU100',null,
           (select trim(max(u2.titulo)) || ' - '||p.titulo || ' - '|| to_char(sum(case when situacao in (1,2,3) -- c lista de estados: Liberado, gerado, pago
            then 1 else 0 end))||'/'||to_char(sum(1)) 
             from demanda d2, solicitacaoentidade se2, uo u2
                 where se2.solicitacao = d2.demanda_id 
                   and se2.projeto = se.projeto 
                   and u2.id = p.uo_id
                   and d2.formulario_id = 1), --z),
            (select uo.titulo from uo where uo.id = p.uo_id) UO,
            (select cia.titulo
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id) CR,
            null,null,null,null,null,null,null,sysdate
from demanda d, solicitacaoentidade se, projeto p
where  se.solicitacao = d.demanda_id 
  and se.projeto = p.id 
  and d.situacao = 1 --y1
  and d.formulario_id = 1 --z

*/

  select count(*) INTO c 
      from estado_regra_condicional where estado_id = 1--y2 
                                    and formulario_id =1;-- z;
                                    
  if c>0 then
--   ls_erro:='Erro. Foi configurado alguma regra condicional para os Estado. Abortado';
   ln_retorno:=-1;
   return;
  end if;

 ls_query:='
      select ''A'',''I'',''TRACE'',''1'',''Trace'',null,
            -- Atributo da Demanda
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data,
            -- Atributo da Demanda
            (select av.valornumerico from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--x
            ) Valor ,
            null,null,null,
            sysdate,
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data2,
            null,null,null,null,null,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--a
            ) Cta_Fluxo ,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--b
            ) Cta_Contabil ,
            ''UU100'',null,
           (select trim(max(u2.titulo)) || '' - ''||p.titulo || '' - ''|| to_char(sum(case when situacao in (1,2,3) -- c lista de estados: Liberado, gerado, pago
            then 1 else 0 end))||''/''||to_char(sum(1)) 
             from demanda d2, solicitacaoentidade se2, uo u2
                 where se2.solicitacao = d2.demanda_id 
                   and se2.projeto = se.projeto 
                   and u2.id = p.uo_id
                   and d2.formulario_id = 1), --z)
            (select uo.titulo from uo where uo.id = p.uo_id) UO,
            (select cia.titulo
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id) CR,
            null,null,null,null,null,null,null,sysdate
      from demanda d, solicitacaoentidade se, projeto p
      where  se.solicitacao = d.demanda_id 
         and se.projeto = p.id ';
--         and d.situacao = 1 --y1
--         and d.formulario_id = 1 --z';

--if 1>2 then PULA TUDO

  DBMS_LOB.CREATETEMPORARY(blob_edit,TRUE);
   
  ls_seperador_campo:=chr(9);
  ls_seperador_registro:=chr(13)||chr(10);
  c := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE (c, ls_query, DBMS_SQL.NATIVE);

  select count(*) into ln_qtde_campos  from table(f_lista_campos_DOF);

  FOR i IN 1 .. ln_qtde_campos
    LOOP

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos_DOF) where sec=i;

      BEGIN
        if reg(1).tipo='char' or reg(1).tipo='fixo' then
           DBMS_SQL.define_column(c, i, ls_campo, 2000);
        end if;
        if reg(1).tipo='number' then
           DBMS_SQL.define_column(c, i, ln_campo);
        end if;
        if reg(1).tipo='date' then
           DBMS_SQL.define_column(c, i, ld_campo);
        end if;        

        l_colcnt := i;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1007)
          THEN
            EXIT;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP; 
   DBMS_SQL.define_column(c, 1, ls_campo, 2000);
   fdbk:= DBMS_SQL.EXECUTE (c); 

 LOOP
  EXIT WHEN(DBMS_SQL.fetch_rows(c) <= 0); 

  ls_linha:='';


  FOR i IN 1 .. ln_qtde_campos
      LOOP
     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos_DOF) where sec=i;

     if reg(1).tipo='char' then
        DBMS_SQL.COLUMN_VALUE(c, i, ls_campo);
        if reg(1).formato='X' THEN
           ls_linha := ls_linha || substr(ls_campo,1,reg(1).tamanho);
        end if;
        if reg(1).formato='X ' THEN
           ls_linha := ls_linha || rpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        if reg(1).formato=' X' THEN
           ls_linha := ls_linha || lpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        end if;
     if reg(1).tipo='fixo' then
        ls_linha := ls_linha || reg(1).formato;
     end if;
     if reg(1).tipo='date' then
        DBMS_SQL.COLUMN_VALUE(c, i, ld_campo);
        ls_linha := ls_linha || to_char(ld_campo,reg(1).formato);
     end if;
     if reg(1).tipo='number' then
        DBMS_SQL.COLUMN_VALUE(c, i, ln_campo);
        ls_linha := ls_linha || to_char(ln_campo,reg(1).formato);
     end if;

     if i <> ln_qtde_campos then
        ls_linha :=ls_linha || ls_seperador_campo;
     else
        ls_linha :=ls_linha || ls_seperador_registro;
     end if;
        
      END LOOP;    

    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));

    ln_registros:=ln_registros+1;
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

  update demanda
  set situacao = 1--y2
  where situacao = 1--y1 
    and formulario_id = -1; --z';

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,'DOF Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

-- Salva em Arquivo Inicio

  select sysdate into ld_data_hora from dual;
  v_chunksize := DBMS_LOB.GETCHUNKSIZE(blob_edit);

    IF (v_chunksize < 32767) THEN
        v_buffer_size := v_chunksize;
    ELSE
        v_buffer_size := 32767;
    END IF;

    v_amount := v_buffer_size;

--    DBMS_LOB.OPEN(v_lob_loc, DBMS_LOB.LOB_READONLY);

    v_out_file := UTL_FILE.FOPEN(
        location      => ls_diretorio, 
        filename      => ls_tipo || '_Trace_para_Zeus_' || to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 
        open_mode     => 'w',
        max_linesize  => 32767);

    WHILE v_amount >= v_buffer_size
    LOOP

      DBMS_LOB.READ(
          lob_loc    => blob_edit,
          amount     => v_amount,
          offset     => v_offset,
          buffer     => v_buffer);

      v_offset := v_offset + v_amount;

      UTL_FILE.PUT_RAW (
          file      => v_out_file,
          buffer    => v_buffer,
          autoflush => true);

      UTL_FILE.FFLUSH(file => v_out_file);


    END LOOP;

    UTL_FILE.FFLUSH(file => v_out_file);

    UTL_FILE.FCLOSE(v_out_file);

    -- +-------------------------------------------------------------+
    -- | CLOSING THE LOB IS MANDATORY IF YOU HAVE OPENED IT          |
    -- +-------------------------------------------------------------+
--    DBMS_LOB.CLOSE(blob_edit);

-- Salva em Arquivo Fim


 dbms_lob.FREETEMPORARY(blob_edit);

 DBMS_SQL.CLOSE_CURSOR (c);
 ln_arquivo:=ln_doc;

--end if; PULA TUDO
-- ln_arquivo:=1000;
 ln_retorno:=ln_registros;
-- raise_application_error(-20001, 'Erro indefinido para testes');

end p_Exporta_Arquivo_CNI;

end PCK_DOCUMENTO;
/

CREATE OR REPLACE PACKAGE PCK_VALIDA_DEMANDA AS
       procedure executa(p_usuario varchar2, p_demanda_id varchar2, p_proximo_estado varchar2, ret in out varchar2);
       function F_VERIFICA_PERM_EDICAO_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2, vpossuiPermissao in out varchar2, pregra_id number) return varchar2;
       function F_VERIFICA_ITENS_TRANSICAO_DEM (pdemanda_id varchar2, pestado_destino varchar2) return varchar2;
       function F_VERIFICA_PERM_CAMPOS_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2;
       function F_VERIFICA_PERM_ATR_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2;
       procedure p_verifica_campos_e_atributos(pusuario_id varchar2, pdemanda_id varchar2, pagendamento_id varchar2, ret in out varchar2);

end PCK_VALIDA_DEMANDA;
/
CREATE OR REPLACE PACKAGE BODY "PCK_VALIDA_DEMANDA" as

procedure executa(p_usuario varchar2, p_demanda_id varchar2, p_proximo_estado varchar2, ret in out varchar2) is
 v_permissao_estado varchar2(2) := 'N';
 v_retorno_edicao varchar2(4000);
 v_retorno_campos varchar2(4000);
 v_retorno_atr varchar2(4000);
 v_retorno_transicao varchar2(4000);
 v_retorno_regras varchar2(4000);

 vn_ret number;
 vn_estado_id number;
 vn_estado_mensagem_id number;
 vn_enviar_email number;
 vn_gerar_baseline number;

 ln_count1 binary_integer;
 ln_count2 binary_integer;
 lt_regras pck_geral.t_varchar_array;
 lt_regra_interna pck_geral.t_varchar_array;
 lt_campos pck_geral.t_varchar_array;
 lt_campo_interno pck_geral.t_varchar_array;
 lt_atr pck_geral.t_varchar_array;
 lt_atr_interno pck_geral.t_varchar_array;
 lt_outros_obrigatorios pck_geral.t_varchar_array;
 t_demanda_id pck_geral.t_varchar_array;

 vn_id_indicador number;
 contador number;
 existe varchar2(2) := 'N';
 ln_contador binary_integer := 0;


begin
   -- executa verificação de permissão no estado
   v_retorno_edicao := f_verifica_perm_edicao_demanda(p_usuario, p_demanda_id, v_permissao_estado, null);

   if v_permissao_estado = 'N' then
     dbms_output.put_line('##### NAO TEM PERMISSAO EDICAO NO ESTADO: '|| v_retorno_edicao);
     ret := v_retorno_edicao; --retorna a violação de permissão de edição no estado
   else
     v_retorno_transicao := f_verifica_itens_transicao_dem(p_demanda_id, p_proximo_estado);

     if v_retorno_transicao is not null then
        dbms_output.put_line('NAO TEM PERMISSAO TRANSICAO: '|| v_retorno_transicao);
        ret := v_retorno_transicao; --retorna a violação de permissão de transição
     else
        v_retorno_campos := f_verifica_perm_campos_demanda(p_usuario, p_demanda_id);
        v_retorno_atr := f_verifica_perm_atr_demanda(p_usuario, p_demanda_id);

        t_demanda_id := pck_geral.f_split(p_demanda_id, ',');

        for contador in 1..t_demanda_id.count loop
            pck_condicional.p_executarregrascondicionaisp(pn_demanda_id => t_demanda_id(contador),
                                                pn_prox_estado => '',
                                                pv_usuario => p_usuario,
                                                pn_ret => vn_ret,
                                                pn_estado_id => vn_estado_id,
                                                pn_estado_mensagem_id => vn_estado_mensagem_id,
                                                pn_enviar_email => vn_enviar_email,
                                                pn_gerar_baseline => vn_gerar_baseline,
                                                pv_retorno_campos => v_retorno_regras);
         end loop;

        dbms_output.put_line('v_retorno_campos: '|| v_retorno_campos);
        dbms_output.put_line('v_retorno_atr: '|| v_retorno_atr);
        dbms_output.put_line('v_retorno_regras: '|| v_retorno_regras);


        lt_campos := pck_geral.f_split(v_retorno_campos, '/');
        lt_atr := pck_geral.f_split(v_retorno_atr, '/');
        lt_regras := pck_geral.f_split(v_retorno_regras, '/');


        dbms_output.put_line('lt_campos: '|| lt_campos.count);
        dbms_output.put_line('lt_atr: '|| lt_atr.count);
        dbms_output.put_line('lt_regras: '|| lt_regras.count);


         for ln_count1 in 1..lt_regras.count loop

           lt_regra_interna := pck_geral.f_split(lt_regras(ln_count1), ',');

           dbms_output.put_line('OPCIONAL OU OBRIGATORIO: '|| lt_regra_interna(2));

           if lt_regra_interna(2) = 'OP' then

              dbms_output.put_line('ATR? : '|| substr(lt_regra_interna(1), 1, 3));

              if substr(lt_regra_interna(1), 1, 3) = 'ATR' then
                for ln_count2 in 1..lt_atr.count loop
                  lt_atr_interno := pck_geral.f_split(lt_atr(ln_count2), ',');

                  dbms_output.put_line('lt_atr_interno(2): '|| lt_atr_interno(2));
                  dbms_output.put_line('lt_campo_interno(1): '|| lt_regra_interna(1));

                  if lt_atr_interno(2) = lt_regra_interna(1) then
                    lt_atr(ln_count2) := ''; --retira o atributo das pendencias
                  end if;
                end loop;
              else
                for ln_count2 in 1..lt_campos.count loop
                  lt_campo_interno := pck_geral.f_split(lt_campos(ln_count2), ',');

                  dbms_output.put_line('lt_campo_interno(1): '|| lt_campo_interno(1));
                  dbms_output.put_line('lt_campo_interno(1): '|| lt_regra_interna(1));

                  if lt_campo_interno(2) = lt_regra_interna(1) then
                    lt_campos(ln_count2) := ''; --retira o campo das pendencias
                  end if;
                end loop;
              end if;

           elsif lt_regra_interna(2) = 'OB' then
                  -- adiciona aqui outros campos obrigatorios

                  if substr(lt_regra_interna(1), 1, 3) = 'ATR' then -- é um atributo
                    dbms_output.put_line('lt_regra_interna(1): '|| lt_regra_interna(1));
                    vn_id_indicador := substr(lt_regra_interna(1), 5, length(lt_regra_interna(1)));

                    dbms_output.put_line('vn_id_indicador: '|| vn_id_indicador);
                    dbms_output.put_line('id_demanda: '|| lt_regra_interna(3));

                     select count(*) into contador
                     from atributo_valor av
                     where av.atributo_id = vn_id_indicador
                     and demanda_id = lt_regra_interna(3);

                     if contador <= 0 then --não existe valor para o atributo OBRIGATORIO
                        existe := 'N';
                        for ln_count2 in 1..lt_atr.count loop --verifica se já foi adicionado na lista de ATRIBUTOS
                            lt_atr_interno := pck_geral.f_split(lt_atr(ln_count2), ',');
                            if lt_atr_interno(2) = vn_id_indicador then
                              existe := 'S';
                            end if;
                        end loop;

                        if existe <> 'S' then
                          ln_contador := ln_contador + 1;
                          dbms_output.put_line('>>>>>>>> '|| lt_regra_interna(1) || ' -- '|| lt_regra_interna(2) || ' -- '|| lt_regra_interna(3));
                          lt_outros_obrigatorios(ln_contador) := lt_regra_interna(1) || ',' || lt_regra_interna(2) || ',' || lt_regra_interna(3) || '/';
                        end if;
                     end if;
                  else  --  é um campo do formulário

                    dbms_output.put_line('é um campo do formulário');

                    existe := 'N';
                    for ln_count2 in 1..lt_campos.count loop --verifica se já foi adicionado na lista de CAMPOS
                        lt_campo_interno := pck_geral.f_split(lt_campos(ln_count2), ',');
                        if lt_campo_interno(2) = lt_regra_interna(1) then
                          existe := 'S';
                        end if;
                    end loop;

                    if existe <> 'S' then
                      ln_contador := ln_contador + 1;
                      lt_outros_obrigatorios(ln_contador) := lt_regra_interna(1) || ',' || lt_regra_interna(2) || ',' || lt_regra_interna(3) || '/';
                    end if;

                  end if;
           end if;
         end loop;

         for ln_count2 in 1..lt_campos.count loop
           ret := ret || lt_campos(ln_count2) || '/';
         end loop;

         for ln_count2 in 1..lt_atr.count loop
           ret := ret || lt_atr(ln_count2) || '/';
         end loop;

         for ln_count2 in 1..lt_outros_obrigatorios.count loop
           ret := ret || lt_outros_obrigatorios(ln_count2) || '/';
         end loop;
         -- LOGAR Zarpelon INICIO


         -- LOGAR Zarpelon FIM
         
      end if;
   end if;
  --commit;
end;


function F_VERIFICA_PERM_EDICAO_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2, vpossuiPermissao in out varchar2, pregra_id number) return varchar2 is
 Result varchar(4000);

 contador binary_integer := 0;
 contador2 binary_integer := 0;
 lv_sql varchar2(32000);
 type t_sql is ref cursor;
 lc_sql t_sql;
 cursor c_dom is select rft.tipo, de.demanda_id from regra_formulario_tipo rft, estado_formulario ef, demanda de;
 dom c_dom%rowtype;

begin

  if pregra_id is null then
     lv_sql := 'select rft.tipo, de.demanda_id '||
              ' from regra_formulario_tipo rft, estado_formulario ef, demanda de '||
              ' where de.demanda_id in ('||pdemanda_id||') '||
              ' and de.formulario_id = ef.formulario_id '||
              ' and de.situacao = ef.estado_id '||
              ' and rft.regra_id = ef.regra_id '||
              ' and rft.formulario_id = ef.formulario_id ';
   else
     lv_sql := 'select rft.tipo, de.demanda_id '||
              ' from regra_formulario_tipo rft, estado_formulario ef, demanda de '||
              ' where de.demanda_id in ('||pdemanda_id||') '||
              ' and de.formulario_id = ef.formulario_id '||
              ' and de.situacao = ef.estado_id '||
              ' and rft.regra_id = '|| pregra_id || ' ' ||
              ' and rft.formulario_id = ef.formulario_id ';
   end if;

    open lc_sql for lv_sql;
    while true loop
      fetch lc_sql into dom;
      exit when lc_sql%notfound;
     if dom.tipo = 'C' then -- CRIADOR
            select count(*) into contador
            from demanda where demanda_id = dom.demanda_id
            and criador = pusuario_id;
            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;
     elsif dom.tipo = 'CE' then -- SOMENTE CONTADOS DA EMPRESA DO SOLICITANTE
            select count(*) into contador from usuario u, demanda de, usuario c
            where de.demanda_id = dom.demanda_id
            and de.solicitante = u.usuarioid
            and c.empresaid = u.empresaid
            and c.tipo_usuario = 'C'
            and c.usuarioid in (pusuario_id);

           if contador > 0 then
             Result := Result || dom.tipo || ',S,' || dom.demanda_id || '/';
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'E' then -- EQUIPE
           select count(*) into contador from regra_formulario_equipe rfe, usuario_equipe ue, demanda de
           where rfe.formulario_id = de.formulario_id
           and de.demanda_id = dom.demanda_id
           and rfe.equipe_id = ue.equipe_id
           and ue.usuarioid = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'P' then -- PERFIL

           select count(*) into contador from
           estado_formulario ef,  regra_formulario_perfil rfp, usuario_perfil up, demanda de
           where de.demanda_id = dom.demanda_id
           and ef.estado_id = de.situacao
           and ef.formulario_id = de.formulario_id
           and nvl(pregra_id, rfp.regra_id) = ef.regra_id
           and rfp.formulario_id = ef.formulario_id
           and up.perfilid = rfp.perfil_id
           and up.usuarioid = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'R' then -- RESPONSAVEL PELO DESTINO

           select count(*) into contador from regra_destino rd, demanda de, estado_formulario ef
           where rd.formulario_id = de.formulario_id
           and de.demanda_id = dom.demanda_id
           and rd.destino_id = de.destino_id
           and ef.formulario_id = de.formulario_id
           and ef.estado_id = de.situacao
           and nvl(pregra_id, rd.regra_id) = ef.regra_id;
           
           select count(*) into contador2 
           from demanda de, destino_usuario du
           where demanda_id = dom.demanda_id
           and de.destino_id = du.destino
           and du.usuario = pusuario_id;

           if contador+contador2 > 0 then
             vpossuiPermissao := 'S';
             dbms_output.put_line('pregra_id: '|| pregra_id);
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'RA' then -- RESPONSAVEL DE ATENDIMENTO
           select count(*) into contador
           from demanda de
           where de.responsavel = pusuario_id
           and de.demanda_id = dom.demanda_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'RC' then -- RESPONSAVEL DO CRIADOR
           select count(*) into contador
           from demanda de, usuario u
           where de.criador = u.usuarioid
           and de.demanda_id = dom.demanda_id
           and u.responsavel_id = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'RS' then -- RESPONSAVEL DO SOLICITANTE
           select count(*) into contador
           from demanda de, usuario u
           where de.solicitante = u.usuarioid
           and de.demanda_id = dom.demanda_id
           and u.responsavel_id = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'S' then -- SOLICITANTE
           select count(*) into contador
           from demanda de
           where de.solicitante = pusuario_id
           and de.demanda_id = dom.demanda_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
             Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'UC' then -- 1º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO CRIADOR
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.criador = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'UC2' then -- 2º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO CRIADOR
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.criador = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel_2 = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'UE' then -- USUARIOS ESPECIFICOS
           select count(*) into contador
           from demanda de, regra_formulario rf, estado_formulario ef, atributo_valor av
           where rf.formulario_id = de.formulario_id
           and ef.formulario_id = de.formulario_id
           and ef.regra_id = nvl(pregra_id, rf.regra_id)
           and ef.estado_id = de.situacao
           and de.demanda_id = dom.demanda_id
           and av.atributo_id = rf.atributo_id(+)
           and de.demanda_id(+) = av.demanda_id
           and av.valor = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'US' then -- 1º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO SOLICITANTE
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.solicitante = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'US2' then -- 2º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO SOLICITANTE
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.solicitante = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel_2 = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;
     end if;

     if vpossuiPermissao = 'S' then
       exit;
     end if;
  end loop;
 return Result;
end;

function F_VERIFICA_ITENS_TRANSICAO_DEM (pdemanda_id varchar2, pestado_destino varchar2) return varchar2 is
  Result varchar2(4000);
  rec_demanda demanda%rowtype;
  contador number;
  contador2 number;
  idDemandas pck_geral.t_varchar_array;
  idProximosEstados pck_geral.t_varchar_array;
begin

  idDemandas := pck_geral.f_split(pdemanda_id, ',');
  idProximosEstados := pck_geral.f_split(pestado_destino, ',');

  for contador2 in 1..idDemandas.count loop
    for dom in (select de.demanda_id, te.obrigar_documento, te.obrigar_ter_documento, te.obrigar_entidade, te.obrigar_ter_entidade from transicao_estado te, demanda de
              where te.formulario_id = de.formulario_id
              and te.estado_id = de.situacao
              and de.demanda_id = idDemandas(contador2)
              and te.estado_destino_id = idProximosEstados(contador2)) loop

             if dom.obrigar_documento = 'S' then

                select count(*) into contador from documento
                where tipoentidade = 'D'
                and identidade = dom.demanda_id;

                if contador <= 0 then
                  Result := Result || 'TRANSICAO,' || 'OBRIGAR_DOCUMENTO' || ',' || dom.demanda_id || '/';
                end if;
             end if;
             if dom.obrigar_ter_documento = 'S' then
              begin
              select de.* into rec_demanda from demanda de
              where de.demanda_id = dom.demanda_id;
              exception when others then
              rec_demanda := null;
              end;

               if rec_demanda.documento_vinc_estado <> 'S' then
                 Result := Result || 'TRANSICAO,' || 'OBRIGAR_TER_DOCUMENTO' || ',' || dom.demanda_id || '/';
               end if;
             end if;
             if dom.obrigar_entidade = 'S' then
               select count(*) into contador
               from solicitacaoentidade
               where solicitacao = dom.demanda_id;

               if contador <= 0 then
                  Result := Result || 'TRANSICAO,' || 'OBRIGAR_ENTIDADE' || ',' || dom.demanda_id || '/';
               end if;
             end if;
             if dom.obrigar_ter_entidade = 'S' then

               select de.* into rec_demanda from demanda de
               where de.demanda_id = dom.demanda_id;

               if rec_demanda.entidade_vinc_estado <> 'S' then
                  Result := Result || 'TRANSICAO,' || 'OBRIGAR_TER_ENTIDADE' || ',' || dom.demanda_id || '/';
               end if;
             end if;
       end loop;
  end loop;
  return(Result);
end;

function F_VERIFICA_PERM_CAMPOS_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2 is
  Result varchar2(4000);
  vcampo varchar2(1000);
  rec_demanda demanda%rowtype;
  contador binary_integer := 0;
  v_permissao_campo varchar2(2) := 'N';
  v_retorno_qualquer varchar2(4000);
  lv_sql varchar2(32000);
  type t_sql is ref cursor;
  lc_sql t_sql;
  cursor c_dom is select cf.chave_campo, de.demanda_id, cf.regra_id from demanda de, campo_formulario_estado cfe, campo_formulario cf;
  dom c_dom%rowtype;

begin

  lv_sql := 'select cf.chave_campo, de.demanda_id, cf.regra_id '||
              'from demanda de, campo_formulario_estado cfe, campo_formulario cf '||
              'where de.demanda_id in ('||pdemanda_id||') '||
              'and cfe.formulario_id = de.formulario_id '||
              'and cfe.estado_id = de.situacao '||
              'and cfe.campo_invisivel = ''N'' '||
              'and cfe.campo_bloqueado = ''N'' '||
              'and cf.formulario_id = de.formulario_id '||
              'and cf.chave_campo = cfe.chave_campo '||
              'and cf.visivel = ''S'' '||
              'and cf.obrigatorio = ''S'' ';


  open lc_sql for lv_sql;
    while true loop
      fetch lc_sql into dom;
      exit when lc_sql%notfound;

              if dom.chave_campo = 'BENEFICIO' then
                 begin
                  select descricao into vcampo from beneficio
                  where demanda_id = dom.demanda_id;
                 exception when others then
                           vcampo:=null;
                 end;

                 if dom.regra_id is not null and pusuario_id is not null then
                   v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                 end if;

                 if (vcampo is null and dom.regra_id is null) or
                   (dom.regra_id is not null and v_permissao_campo = 'S' and vcampo is null) then
                    Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id ||'/';
                 end if;

              elsif dom.chave_campo = 'BENEFICIO_VALOR' then
                 begin
                 select valor into vcampo from beneficio
                 where demanda_id = dom.demanda_id;
                 exception when others then
                 vcampo := null;
                 end;

                 if dom.regra_id is not null and pusuario_id is not null then
                   v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                 end if;

                 if (vcampo is null and dom.regra_id is null) or
                   (dom.regra_id is not null and v_permissao_campo = 'S' and vcampo is null) then
                    Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id ||'/';
                 end if;
              elsif dom.chave_campo = 'DATAS_PREVISTAS' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                   if (dom.regra_id is not null and v_permissao_campo = 'S' and (rec_demanda.data_inicio_previsto is null or rec_demanda.data_fim_previsto is null)) or
                     ((rec_demanda.data_inicio_previsto is null or rec_demanda.data_fim_previsto is null) and dom.regra_id is null) then
                     Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                   end if;

              elsif dom.chave_campo = 'DATAS_REALIZADAS' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (dom.regra_id is not null and v_permissao_campo = 'S' and (rec_demanda.data_inicio_atendimento is null or rec_demanda.data_fim_atendimento is null)) or
                     ((rec_demanda.data_inicio_atendimento is null or rec_demanda.data_fim_atendimento is null) and dom.regra_id is null) then
                      Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'DESTINO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.destino_id is null and dom.regra_id is null) or
                      (rec_demanda.destino_id is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;

              elsif dom.chave_campo = 'INTERESSADOS' then
                    
                    select count(*) into contador
                    from parte_interessada
                    where demanda_id = dom.demanda_id;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (contador <= 0 and dom.regra_id is null) or
                      (contador <= 0 and dom.regra_id is not null and v_permissao_campo = 'S')then
                      Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              /* CAMPO MOTIVO NAO EXISTE MAIS NO FORMULARIO
               elsif dom.chave_campo = 'MOTIVO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.motivo is null and dom.regra_id is null) or
                      (rec_demanda.motivo is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;*/

              elsif dom.chave_campo = 'OUTRO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.outro is null and dom.regra_id is null) or
                      (rec_demanda.outro is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'PESO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.peso is null and dom.regra_id is null) or
                      (rec_demanda.peso is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'PRIORIDADE' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.prioridade is null and dom.regra_id is null) or
                      (rec_demanda.prioridade is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'PRIORIDADE_ATENDIMENTO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    dbms_output.put_line('v_permissao_campo: '|| v_permissao_campo || ' - dom.regra_id: '|| dom.regra_id);

                    if (rec_demanda.prioridade_responsavel is null and dom.regra_id is null) or
                      (rec_demanda.prioridade_responsavel is null and dom.regra_id is not null and v_permissao_campo = 'S') then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'RESPONSAVEL' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.responsavel is null and dom.regra_id is null) or
                      (rec_demanda.responsavel is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'SOLICITANTE' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.solicitante is null and dom.regra_id is null) or
                      (rec_demanda.solicitante is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'TIPO' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.tipo is null and dom.regra_id is null) or
                      (rec_demanda.tipo is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'TITULO' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.titulo is null and dom.regra_id is null) or
                      (rec_demanda.titulo is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              end if;
              v_permissao_campo := 'N';
   end loop;

  return(Result);
end;

function F_VERIFICA_PERM_ATR_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2 is
  Result varchar2(4000);
  contador binary_integer := 0;
  v_permissao_campo varchar2(2) := 'N';
  v_retorno_qualquer varchar2(4000);

  lv_sql varchar2(32000);
  type t_sql is ref cursor;
  lc_sql t_sql;
  cursor c_dom is select de.demanda_id, a.atributoid, te.texto_termo, te.idioma, a.tipo, sa.regra_id from demanda de, atributo_form_estado afe, secao_atributo sa, atributo a, termo te;
  dom c_dom%rowtype;
begin

  lv_sql := 'select de.demanda_id, a.atributoid, te.texto_termo, te.idioma, a.tipo, sa.regra_id '||
             'from demanda de, atributo_form_estado afe, secao_atributo sa, atributo a, termo te '||
             'where de.demanda_id in ('|| pdemanda_id || ') '||
             'and afe.formulario_id = de.formulario_id '||
             'and afe.estado_id = de.situacao '||
             'and afe.campo_invisivel = ''N'' '||
             'and afe.campo_bloqueado = ''N'' '||
             'and sa.formulario_id = de.formulario_id '||
             'and sa.atributo_id = afe.atributo_id '||
             'and sa.obrigatorio = ''S'' '||
             'and sa.vigente = ''S'' '||
             'and sa.visivel = ''S'' '||
             'and a.atributoid = sa.atributo_id '||
             'and a.titulo_termo_id = te.termo_id ';

  open lc_sql for lv_sql;
    while true loop
      fetch lc_sql into dom;
      exit when lc_sql%notfound;

             select count(*) into contador
              from atributo_valor av
              where av.atributo_id = dom.atributoid
              and demanda_id = dom.demanda_id;

              dbms_output.put_line('atributo ::::::::::::: '|| dom.atributoid);

             if dom.regra_id is not null and pusuario_id is not null then
                 v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
              end if;

              if (contador <= 0 and dom.regra_id is null) or
                (contador <= 0  and dom.regra_id is not null and v_permissao_campo = 'S') then
                Result := Result || 'ATR' || ',' || dom.atributoid || ',' || dom.demanda_id || '/';
              end if;

  end loop;
  return(Result);
end;

procedure p_verifica_campos_e_atributos(pusuario_id varchar2, pdemanda_id varchar2, pagendamento_id varchar2, ret in out varchar2) is
ret1 varchar2(100);
ret2 varchar2(100);
  begin
  ret1:=F_VERIFICA_PERM_CAMPOS_DEMANDA(pusuario_id, pdemanda_id);
  ret2:=F_VERIFICA_PERM_ATR_DEMANDA(pusuario_id, pdemanda_id);
  ret:=nvl(ret1,'')||nvl(ret2,'');  

   -- LOGAR Zarpelon INICIO

    insert into AGENDAMENTO_TRANSICAO_EST_LOG (id,agendamento_id,data_execucao,demanda_id,estado_atual_id, 
                                               estado_destino_id, executado, mensagem)
    select AGENDAMENTO_TRAN_EST_LOG_SEQ.Nextval, a.id, sysdate, 
           a.demanda_id, (select max(h2.id) from h_demanda h2 where h2.demanda_id=a.demanda_id),
           a.estado_destino,case when trim(nvl(ret1,'')||nvl(ret2,'')) is null then 'Y' else 'N' end,
           nvl(ret1,'')||nvl(ret2,'')
    from AGENDAMENTO_TRANSICAO_ESTADO a where a.id=pagendamento_id;

   -- LOGAR Zarpelon FIM
  
  end;
  
end PCK_VALIDA_DEMANDA;
/


-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '03', 3, 'Aplicação de patch (parte 4)');
commit;
/
                    
select * from v_versao;
/

