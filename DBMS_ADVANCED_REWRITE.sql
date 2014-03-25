---------- criar ambiente ----------------
CONN test/test

DROP TABLE rewrite_test_tab;

CREATE TABLE rewrite_test_tab (
  id           NUMBER,
  description  VARCHAR2(50),
  CONSTRAINT rewrite_test_tab_pk PRIMARY KEY (id)
);

INSERT INTO rewrite_test_tab (id, description) VALUES (1, 'GLASGOW');
INSERT INTO rewrite_test_tab (id, description) VALUES (2, 'BIRMINGHAM');
INSERT INTO rewrite_test_tab (id, description) VALUES (3, 'LONDON');
COMMIT;

EXEC DBMS_STATS.gather_table_stats(USER, 'rewrite_test_tab');


-------------- criar equivalencia ------------------
BEGIN
  SYS.DBMS_ADVANCED_REWRITE.declare_rewrite_equivalence (
     name             => 'test_rewrite',
     source_stmt      => 'SELECT * FROM rewrite_test_tab',
     destination_stmt => 'SELECT id, lower(description) teste FROM rewrite_test_tab',
     validate         => FALSE,
     rewrite_mode     => 'TEXT_MATCH');
END;

----------------------------------------------------


-------------- usando --------------------------

ALTER SESSION SET QUERY_REWRITE_INTEGRITY = TRUSTED;

Session altered.

SELECT * FROM rewrite_test_tab;

------------------------------------------------


visualizar os configurados
SELECT * FROM user_rewrite_equivalences;



