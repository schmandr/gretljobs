SELECT 
	t_ili_tid,
	prozessa, 
	gef_stufe, 
	aindex, 
	bemerkung, 
	gk_art, 
	publiziert, 
	ngkid, 
	geometrie
FROM 
	afu_gefahrenkartierung.gefahrenkartirung_gk_sturz
WHERE
	gef_stufe != 'keine'
	AND
	publiziert = true
;