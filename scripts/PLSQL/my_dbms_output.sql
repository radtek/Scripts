create or replace package ilegra_tst.ilg_dbms_output
as
    procedure put( s in varchar2 );
    procedure put_line( s in varchar2 );
    procedure new_line;
    function get_line( n in number ) return varchar2;
    pragma restrict_references( get_line, wnds, rnds );
    function get_line_count return number;
    pragma restrict_references( get_line_count, wnds, rnds, wnps );
    pragma restrict_references( ilg_dbms_output, wnds, rnds, wnps, rnps );
end;
/

 create or replace package body ilegra_tst.ilg_dbms_output 
 as                                                                                                                        
  type Array is table of varchar2(4000) index by binary_integer;
  g_data        array;                                         
  g_cnt        number default 1;                                                                                        
     procedure put( s in varchar2 )                           
     is                                                       
     begin                                                    
         if ( g_data.last is not null ) then                  
             g_data(g_data.last) := g_data(g_data.last) || s; 
         else                                                 
             g_data(1) := s;                                  
         end if;                                              
     end;                                                     
     procedure put_line( s in varchar2 )                      
     is                                                       
     begin                                                    
         put( s );                                            
         g_data(g_data.last+1) := null;                       
     end;                                                     
     procedure new_line                                       
     is                                                       
     begin                                                    
         put( null );                                         
         g_data(g_data.last+1) := null;                       
     end;                                                                                                                    
     function get_line( n in number ) return varchar2         
     is                                                       
         l_str varchar2(4000) default g_data(n);              
     begin                                                    
         g_data.delete(n);                                    
         return l_str;                                        
     end;                                                                                                                    
     function get_line_count return number                    
     is                                                       
     begin                                                    
         return g_data.count+1;                               
     end;                                                     
                                                              
 end;                                                         
 /                                                            

create or replace view ilegra_test.ilg_dbms_output_view
as
select rownum lineno, my_dbms_output.get_line( rownum ) text
  from all_objects
 where rownum < ( select my_dbms_output.get_line_count from dual );