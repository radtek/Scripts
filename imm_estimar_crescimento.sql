set serveroutput on 
variable dias number
exec :dias := &dias
declare 
	v_nro_dias_historico number := :dias;
	v_cres_medio_diario number;
	v_Mb_Disp_p_db number;
	v_Mb_usado_p_db number;
	v_Nro_dias_estimado_p_cres number;
begin 
	SYSTEM.imm$sgt_pkg.prc_estimativa_crescimento(p_nro_dias_historico => v_nro_dias_historico, 
		o_cres_medio_diario => v_cres_medio_diario,
		o_Mb_Disp_p_db => v_Mb_Disp_p_db,
		o_Mb_usado_p_db => v_Mb_usado_p_db,
		o_Nro_dias_estimado_p_cres => v_Nro_dias_estimado_p_cres);

	DBMS_OUTPUT.PUT_LINE('v_MB_cres_medio_diario = ' || to_char(v_cres_medio_diario) || chr(10) || chr(13) ||
			    'v_Mb_Disp_p_db 	 = ' || to_char(v_Mb_Disp_p_db)      || chr(10) || chr(13)	 ||
			    'v_Mb_usado_p_db 	 = ' || to_char(v_Mb_usado_p_db)      || chr(10) || chr(13) ||
			    'v_Nro_dias_estimado_p_cres = ' || to_char(v_Nro_dias_estimado_p_cres));	
end;
/
undef dias;