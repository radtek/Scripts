
 
11:47:01 pceudb23>DROP INDEX "TPHARMA"."MTLPA_NAME_IDX_X";
�ndice eliminado.

11:40:17 pceudb24>CREATE INDEX "TPHARMA"."MTLPA_NAME_IDX_X" ON "TPHARMA"."MV_TPC_LINK_PATENT_ALL_X" ("NAME")  TABLESPACE "TPHARMA_INDEX" nologging;
�ndice criado.
  
11:47:05 pceudb23>alter index "TPHARMA"."MTLPA_NAME_IDX_X" rebuild nologging;
�ndice alterado.

