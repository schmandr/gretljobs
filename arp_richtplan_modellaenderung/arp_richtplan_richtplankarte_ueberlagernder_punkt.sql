SELECT
    t_id,
    t_ili_tid,
    objekttyp,
    spezifikation,
    objektname,
    abstimmungskategorie,
    bedeutung,
    planungsstand,
    status,
    geometrie
FROM
    arp_richtplan_delete.richtplankarte_ueberlagernder_punkt
;