SELECT 
	t_ili_tid,
	wkp, 
	int_stufe,
	bemerkung, 
	gs_korr,
	ngkid, 
	geometrie
FROM 
	afu_gefahrenkartierung.gefahrenkartirung_ik_hangmure
WHERE
	int_stufe != 'keine'
;
