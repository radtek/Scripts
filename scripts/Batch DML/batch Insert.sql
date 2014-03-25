declare
  cursor c is select * from dual union all select * from dual union all select * from dual union all select * from dual;    
  TYPE ARRAY IS TABLE OF c%ROWTYPE;
  l_data ARRAY;
begin 
    
    OPEN c;
    LOOP
      
      FETCH c BULK COLLECT INTO l_data LIMIT 100;

      FORALL i IN 1..l_data.COUNT
          INSERT INTO x VALUES l_data(i);
      
      commit;
              
      EXIT WHEN c%NOTFOUND;
     
    END LOOP;
    
    CLOSE c;
end;