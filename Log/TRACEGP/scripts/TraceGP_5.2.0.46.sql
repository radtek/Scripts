/*****************************************************************************\ 
 * TraceGP 5.2.0.46                                                          *
\*****************************************************************************/
define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;
-------------------------------------------------------------------------------

-- Create table
create table DASHBOARD_PERFIL (
  dashboard_id NUMBER(10) not null,
  perfil_id    NUMBER(10) not null,
constraint PK_DASHBOARD_PERFIL primary key (dashboard_id, perfil_id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;


-- Create/Recreate primary, unique and foreign key constraints
alter table DASHBOARD_PERFIL add constraint DASHBOARD_PERFIL_01 
  foreign key (DASHBOARD_ID) references DASHBOARD (ID) on delete cascade;
alter table DASHBOARD_PERFIL add constraint DASHBOARD_PERFIL_02 
  foreign key (PERFIL_ID) references PERFIL (PERFILID) on delete cascade;
  
-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '46', 2, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                    
select * from v_versao;
/
