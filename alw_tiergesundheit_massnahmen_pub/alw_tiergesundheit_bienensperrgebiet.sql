SELECT
    geometrie,
    jahr,
    typ_sperre,
    verwendungszweck,
    datum_installation,
    aktiv,
    datum_inaktiv
FROM
    alw_tiergesundheit_massnahmen.massnhmnrgsndheit_bienensperrgebiet
WHERE
    aktiv = true
;
