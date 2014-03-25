define OWNER='&OWNER'
accept NOT_LIST CHAR prompt "informe se algum usuário para ignorar: "
accept DIAS prompt  "informe o numero de dias para considerar para buscar no AWR: "

prompt
prompt valida as views dba_hist_sql_plan e gv$sql_plan para determinar se o indice esta sendo utilizado ou nao em algum plano
prompt ********* statistics_level deve estar como all *********
show parameter statistics_level
prompt
prompt

select owner, index_name
from dba_indexes
where owner like UPPER('&OWNER')
and owner <> '&NOT_LIST'
and UNIQUENESS = 'NONUNIQUE'  -- indice unico tem regra de negocio envolvido
and index_type not in ('IOT - TOP', 'LOB', 'CLUSTER')
minus
select object_owner, object_name
from (
	select object_owner, object_name
	from dba_hist_sql_plan		
	where object_type = 'INDEX'
	and object_owner like UPPER('&OWNER')
	and object_owner <> '&NOT_LIST'
	and timestamp > sysdate -&DIAS
	union
	select object_owner, object_name
	from gv$sql_plan
	where object_type = 'INDEX'
	and object_owner like UPPER('&OWNER')
	and object_owner <> '&NOT_LIST'
	union 
	select owner, constraint_name -- ignorar as PKs, uks
	from dba_constraints
	where CONSTRAINT_TYPE IN ('P', 'U')
	and owner like UPPER('&OWNER')
	and owner <> '&NOT_LIST'
	union 
	SELECT ind.owner, ind.index_name -- ignorar fks
	FROM (SELECT b.owner,
					   b.table_name,
					   b.constraint_name,
					   MAX(decode(position, 1, column_name, NULL)) cname1,
					   MAX(decode(position, 2, column_name, NULL)) cname2,
					   MAX(decode(position, 3, column_name, NULL)) cname3,
					   MAX(decode(position, 4, column_name, NULL)) cname4,
					   MAX(decode(position, 5, column_name, NULL)) cname5,
					   MAX(decode(position, 6, column_name, NULL)) cname6,
					   MAX(decode(position, 7, column_name, NULL)) cname7,
					   MAX(decode(position, 8, column_name, NULL)) cname8,
					   COUNT(*) col_cnt
				  FROM dba_constraints b
			   inner join dba_cons_columns a
				on a.constraint_name = b.constraint_name
				and a.table_name = b.table_name
				and b.owner = a.owner
				 WHERE b.constraint_type = 'R'
			and b.owner like UPPER('&OWNER')
				 GROUP BY b.owner, b.table_name, b.constraint_name) cons
		inner join (SELECT b.owner,
					   b.table_name,
					   b.index_name,
					   MAX(decode(COLUMN_POSITION, 1, column_name, NULL)) cname1,
					   MAX(decode(COLUMN_POSITION, 2, column_name, NULL)) cname2,
					   MAX(decode(COLUMN_POSITION, 3, column_name, NULL)) cname3,
					   MAX(decode(COLUMN_POSITION, 4, column_name, NULL)) cname4,
					   MAX(decode(COLUMN_POSITION, 5, column_name, NULL)) cname5,
					   MAX(decode(COLUMN_POSITION, 6, column_name, NULL)) cname6,
					   MAX(decode(COLUMN_POSITION, 7, column_name, NULL)) cname7,
					   MAX(decode(COLUMN_POSITION, 8, column_name, NULL)) cname8,
					   COUNT(*) col_cnt
				  FROM dba_indexes b
			   inner join dba_ind_columns a
				on a.index_name = b.index_name
				and a.table_name = b.table_name
				and b.owner = a.index_owner
				and b.table_owner = a.table_owner
				 WHERE  b.owner like UPPER('&OWNER')
				 GROUP BY b.owner, b.table_name, b.index_name) ind
		on ind.owner = cons.owner
			and ind.table_name = cons.table_name
			and coalesce(ind.cname1, '0') = coalesce(cons.cname1, '0')
			and coalesce(ind.cname2, '0') = coalesce(cons.cname2, '0')
			and coalesce(ind.cname3, '0') = coalesce(cons.cname3, '0')
			and coalesce(ind.cname4, '0') = coalesce(cons.cname4, '0')
			and coalesce(ind.cname5, '0') = coalesce(cons.cname5, '0')
			and coalesce(ind.cname6, '0') = coalesce(cons.cname6, '0')
			and coalesce(ind.cname7, '0') = coalesce(cons.cname7, '0')
			and coalesce(ind.cname8, '0') = coalesce(cons.cname8, '0')
);
undefine OWNER
undefine NOT_LIST
undef DIAS