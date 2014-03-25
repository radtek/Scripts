
-------------------- TESTE 1 -----------------------------------------
CREATE OR REPLACE TYPE "OBJ_ALTERA_PRECO" AS OBJECT (
   PRECO_VENDA_ANTERIOR NUMBER(14,2),
   PRECO_VENDA_ATUAL NUMBER(14,2),
   DATA_ULTIMA_ALTERACAO_PRECO DATE,
   DATA_ULTIMA_ATUALIZACAO  DATE,
   DATA_VIGOR_PRECO  DATE,
   PRECO_VENDA_DATA_ALTERACAO NUMBER(14,2),
   ROW_ID VARCHAR2(20)
);


CREATE OR REPLACE TYPE "TP_ALTERA_PRECO"
          AS TABLE OF OBJ_ALTERA_PRECO;
		  
		  
set long 99999999		  
set serveroutput on 

DECLARE 	
	tbl TP_ALTERA_PRECO;	
	item OBJ_ALTERA_PRECO;
	my_cursor SYS_REFCURSOR;
BEGIN 
	tbl:= TP_ALTERA_PRECO();

	tbl.extend;		
	item := OBJ_ALTERA_PRECO(null, null, null, null, null, null, null);
	tbl(tbl.last) := item;
	tbl(tbl.last).PRECO_VENDA_ANTERIOR:=100;
    tbl(tbl.last).PRECO_VENDA_ATUAL:=110;
    tbl(tbl.last).DATA_ULTIMA_ALTERACAO_PRECO:=sysdate;
    tbl(tbl.last).DATA_ULTIMA_ATUALIZACAO:=sysdate;
    tbl(tbl.last).DATA_VIGOR_PRECO:=sysdate;
    tbl(tbl.last).PRECO_VENDA_DATA_ALTERACAO:=1000;
    tbl(tbl.last).ROW_ID:= 'AAAAB0AABAAAAOhAAA';


	tbl.extend;		
	item := OBJ_ALTERA_PRECO(null, null, null, null, null, null, null);
	tbl(tbl.last) := item;
	tbl(tbl.last).PRECO_VENDA_ANTERIOR:=200;
    tbl(tbl.last).PRECO_VENDA_ATUAL:=210;
    tbl(tbl.last).DATA_ULTIMA_ALTERACAO_PRECO:=sysdate;
    tbl(tbl.last).DATA_ULTIMA_ATUALIZACAO:=sysdate;
    tbl(tbl.last).DATA_VIGOR_PRECO:=sysdate;
    tbl(tbl.last).PRECO_VENDA_DATA_ALTERACAO:=1000;
    tbl(tbl.last).ROW_ID:= 'AAAAB0AABAAAAOhAAA';
	
	
	FOR r IN (SELECT PRECO_VENDA_ANTERIOR, PRECO_VENDA_ATUAL, DATA_ULTIMA_ALTERACAO_PRECO, ROW_ID FROM TABLE(CAST(tbl AS TP_ALTERA_PRECO)) ORDER BY 1) 
	LOOP 
		dbms_output.put_line('------- PRECO_VENDA_ANTERIOR: ' || to_char(r.PRECO_VENDA_ANTERIOR) || ' PRECO_VENDA_ATUAL: ' || to_char(r.PRECO_VENDA_ATUAL));
	END LOOP; 
	

	OPEN my_cursor FOR SELECT * FROM TABLE(CAST(tbl AS TP_ALTERA_PRECO));	
	:ref:=my_cursor;
	
	
END;


-------------------- TESTE 2 -----------------------------------------
CREATE OR REPLACE TYPE "OBJ_ALTERA_PRECO" AS OBJECT (
   ID NUMBER,
   VALOR NUMBER(14,2)
);

CREATE OR REPLACE TYPE "TP_ALTERA_PRECO"
          AS TABLE OF OBJ_ALTERA_PRECO;
/


CREATE OR REPLACE TYPE "OBJ_RES_ALTERA_PRECO" AS OBJECT (
   QTD NUMBER
);

CREATE OR REPLACE TYPE "TP_RES_ALTERA_PRECO"
          AS TABLE OF OBJ_RES_ALTERA_PRECO;
/
	 
CREATE OR replace PACKAGE PCK_ATUALIZA_PRECO AS

	type rc_rec IS ref cursor return teste_parallel%rowtype;
END;

create or replace FUNCTION FNC_ATUALIZA_DADOS(p_cursor IN PCK_ATUALIZA_PRECO2.rc_rec) RETURN TP_RES_ALTERA_PRECO
	PIPELINED
	PARALLEL_ENABLE(PARTITION p_cursor BY HASH(ID))
IS
	o_row OBJ_RES_ALTERA_PRECO:= OBJ_RES_ALTERA_PRECO(null);
	
	TYPE id_tab IS TABLE OF teste_parallel%ROWTYPE;
    L_id_tab id_tab;
	L_num number:=0;	
	 PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN

	 LOOP
        FETCH p_cursor BULK COLLECT INTO L_id_tab LIMIT 1000;
		EXIT WHEN L_id_tab.COUNT=0;				
	
		L_num := L_num + L_id_tab.COUNT;
        FOR i IN 1 .. L_id_tab.COUNT LOOP		
			update teste_parallel
			set valor=400
			where ID = L_id_tab(i).ID;
		END  LOOP
		
		COMMIT;			
	END LOOP;			
	
	o_row.qtd:=L_num;
	close p_cursor;
	COMMIT;
	
	PIPE ROW (o_row);	  				
	RETURN;
END FNC_ATUALIZA_DADOS;



SELECT  SUM(QTD) FROM TABLE(FNC_ATUALIZA_DADOS(CURSOR(SELECT /*+ parallel(tbl 4)*/ * FROM teste_parallel tbl))) tbl;	
-------------------- TESTE 2 -----------------------------------------

-------------------- TESTE 3 -----------------------------------------

CREATE OR replace PACKAGE PCK_ATUALIZA_PRECO2 AS
	cursor p_rec IS SELECT /*+ parallel(tbl 4)*/ * FROM teste_parallel tbl;	
	type rc_rec IS ref cursor return p_rec%rowtype;
END;    
	

DECLARE 	
	p_cursor PCK_ATUALIZA_PRECO2.rc_rec;
	
	ctd number;
BEGIN
	OPEN p_cursor FOR SELECT /*+ parallel(tbl 4)*/ * FROM teste_parallel tbl;
	
	SELECT SUM(QTD) 
	INTO ctd
	FROM TABLE(FNC_ATUALIZA_DADOS(p_cursor)) tbl;	
END;
-------------------------------------------------------------