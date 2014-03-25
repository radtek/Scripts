declare
   type tpCursor is ref cursor; 
   ln_proximo number;
   ln_retorno number;
   cID        tpCursor;
begin

   -- Inicia pela atualização da seqüência versao_log_seq
   
   execute immediate 'drop sequence versao_log_seq';
  
   select max(id) + 1 into ln_proximo from versao_log;
  
   if ln_proximo is null or ln_proximo = 0 then
     ln_proximo := 1;
   end if;
   
   execute immediate 'create sequence versao_log_seq start with ' || 
                      ln_proximo || ' increment by 1 nocache';
                      
   execute immediate 'alter package pck_versao compile';
   execute immediate 'alter package pck_processo compile';
   
   pck_processo.precompila; 
   
   -- 
   for seqs in ( select lower(nome_sequencia) nome_sequencia, lower(tabela) tabela, 
                        lower(coluna) coluna
                   from versao_sequencia
                  where lower(nome_sequencia) <> 'versao_log_seq') loop
                
      -- Descobre próximo ID para recriar seqüência        
      if seqs.nome_sequencia = 'usuario_seq' then
         -- Sequence USUARIO_SEQ deve receber tratamento diferenciado, pois aponta a uma coluna VARCHAR2
         begin
         select max(to_number(usuarioid)) + 1 
           into ln_proximo
           from usuario 
          where regexp_instr(usuarioid, '[[:alpha:]]') = 0;
         exception
            when NO_DATA_FOUND then
               ln_proximo := 1;
            when OTHERS then
               ln_proximo := null;
         end; 
      elsif seqs.nome_sequencia = 'projeto_seq' then
         -- Sequence PROJETO_SEQ deve receber tratamento diferenciado, pois é usado em duas tabelas
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
                pck_versao.p_log_versao('E', '[Err] Não foi possível determinar próximo valor para coluna: ' 
                                       || seqs.coluna || ', tabela: ' || seqs.tabela ||' (' || sqlerrm || ')'); 
                ln_proximo := null;
          end;
      end if;  

      --        
      if ln_proximo is not null then
         -- Drop seqüência
         begin
            execute immediate 'drop sequence ' || seqs.nome_sequencia;
         exception
            when OTHERS then
               pck_versao.p_log_versao ('A', '[Adv] Não foi possível remover seqüência ' 
                                        || seqs.nome_sequencia || ' (' || sqlerrm || ')');     
         end;
         -- Cria seqüência 
         begin         
            execute immediate 'create sequence ' || seqs.nome_sequencia || ' start with ' || 
                              ln_proximo || ' increment by 1 nocache';
         exception
            when OTHERS then
               pck_versao.p_log_versao ('E', '[Err] Não foi possível criar seqüência ' 
                                        || seqs.nome_sequencia || ' (' || sqlerrm || ')');        
         end;
      end if;
   end loop;
end;
/

begin
   pck_processo.precompila;
end;
/
