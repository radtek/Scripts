declare 
    begin
        for c_perfil in 
            (select perfilid from perfil)
        loop 
            for c_dashboard in 
                (select id from dashboard d where d.publico = 'Y')
            loop
                insert into dashboard_perfil values (c_dashboard.id, c_perfil.perfilid);
            end loop;
        end loop; 
    end; 

