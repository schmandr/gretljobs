SELECT 
  t_id, 
  t_ili_tid, 
  geometrie, 
  letalitaetsradius_art, 
  letalitaetsradius, 
  bevoelkerung_typ, 
  bevoelkerung_anzahl, 
  risikozahl, 
  anzahl_tote, 
  bemerkung, 
  id_szenario 
FROM 
  ${DB_Schema_QRcat}.qrcat_toxischunguenstigster_sektor;
