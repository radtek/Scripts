declare
   type tpCursor is ref cursor; 
   ln_proximo    number;
   ln_max_usr_id number;
   ln_usr_id     number;
   ln_retorno    number;
   cID           tpCursor;
begin
   -- 
   insert into versao_log(id, datahora, mensagem, tipo)
          values (versao_log_seq.nextval, systimestamp, 
                  'Iniciada atualiza��o de sequences', 'I');                 
   commit;
   --
   for seqs in ( select lower(nome_sequencia) nome_sequencia, lower(tabela) tabela, 
                        lower(coluna) coluna
                   from versao_sequencia
                  where lower(nome_sequencia) <> 'versao_log_seq'
                 order by nome_sequencia) loop
                
      -- Descobre pr�ximo ID para recriar seq��ncia        
      if seqs.nome_sequencia = 'usuario_seq' then
        -- Sequence USUARIO_SEQ deve receber tratamento diferenciado, pois aponta a uma coluna VARCHAR2
        ln_proximo    := 0;
        ln_max_usr_id := 0;   
        for usr in (select usuarioid from usuario) loop
          begin
            ln_usr_id := to_number(usr.usuarioid);
            if ln_usr_id > ln_max_usr_id then
              ln_max_usr_id := ln_usr_id;
            end if;
          exception
            when OTHERS then
              null;
          end;
        end loop;
        ln_proximo := ln_max_usr_id + 1;
                 
      elsif seqs.nome_sequencia = 'projeto_seq' then
         -- Sequence PROJETO_SEQ deve receber tratamento diferenciado, pois � usado em duas tabelas
         select max(ident) + 1
           into ln_proximo
           from ( select nvl(max(id),0) IDENT from projeto
                  union all 
                  select nvl(max(projeto_id),0) from log_exclusao_projeto );
      else
          ---
          begin
             ln_proximo := null;
             open cID for 'select max(' || seqs.coluna ||') + 1 from ' || seqs.tabela; 
             loop
                fetch cID into ln_proximo;
                exit when cID%notfound;
             end loop; -- Cursor cID
   
             if ln_proximo is null then
                ln_proximo := 1;
             end if;
          exception
             when OTHERS then
                pck_versao.p_log_versao('E', '[Err] N�o foi poss�vel determinar pr�ximo valor para coluna: ' 
                                       || seqs.coluna || ', tabela: ' || seqs.tabela ||' (' || sqlerrm || ')'); 
                ln_proximo := null;
          end;
      end if;  

      --        
      if ln_proximo is not null then
         -- Drop seq��ncia
         begin
            execute immediate 'drop sequence ' || seqs.nome_sequencia;
         exception
            when OTHERS then
               pck_versao.p_log_versao ('A', '[Adv] N�o foi poss�vel remover seq��ncia ' 
                                        || seqs.nome_sequencia || ' (' || sqlerrm || ')');     
         end;
         -- Cria seq��ncia 
         begin         
            execute immediate 'create sequence ' || seqs.nome_sequencia || ' start with ' || 
                              ln_proximo || ' increment by 1 nocache';
         exception
            when OTHERS then
               pck_versao.p_log_versao ('E', '[Err] N�o foi poss�vel criar seq��ncia ' 
                                        || seqs.nome_sequencia || ' (' || sqlerrm || ')');        
         end;
         -- Registra opera��o
         insert into versao_log(id, datahora, mensagem, tipo)
                values (versao_log_seq.nextval, systimestamp, '   ' || seqs.nome_sequencia ||
                        ' atualizado para: ' || ln_proximo, 'I');
         commit;
      end if;
   end loop;
   --
   insert into versao_log(id, datahora, mensagem, tipo)
          values (versao_log_seq.nextval, systimestamp, 
                  'Terminada atualiza��o de sequences', 'I');                 
   commit;
end;
/

begin
  pck_processo.pRecompila;
  commit;
end;
/

begin
  for obj in (select * from all_objects where status = 'INVALID') loop
    insert into versao_log(id, datahora, mensagem, tipo)
           values (versao_log_seq.nextval, systimestamp, 
                  'Objeto: ' || obj.object_name ||
                  ' | Tipo: ' || obj.object_type ||
                  ' | Usu�rio (Owner): ' || obj.owner ||
                  ' | Estado (Status): ' || obj.status, 
                  'E');                 
  end loop;
  commit;
end;
/
