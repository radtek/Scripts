col text for a60
SELECT line, position, text
FROM dba_errors
WHERE UPPER(type) LIKE UPPER('&tipo') AND 
UPPER(name) LIKE UPPER('&nome') AND
UPPER(owner) LIKE UPPER('&owner');