SELECT 
	t_ili_tid,
	prozessq, 
	wkp, 
	bemerkung, 
	ueberfl_hb,
	ngkid, 
	geometrie
FROM 
	afu_gefahrenkartierung.gefahrenkartirung_ueberflutungskarte
WHERE
	ueberfl_hb != 'keine_Ueberflutung'
;
