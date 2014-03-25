SET SERVEROUTPUT ON
DECLARE
	l_plans_altered  PLS_INTEGER;
BEGIN
	l_plans_altered := DBMS_SPM.alter_sql_plan_baseline(
	sql_handle      => '&sql_handle',
	plan_name       => '&plan_name',
	attribute_name  => 'fixed',
	attribute_value => 'YES');

	DBMS_OUTPUT.put_line('Plans Altered: ' || l_plans_altered);
END;
/