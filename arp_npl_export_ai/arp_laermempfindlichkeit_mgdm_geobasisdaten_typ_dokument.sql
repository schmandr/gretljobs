INSERT INTO arp_laermempfindlichkeit_mgdm.geobasisdaten_typ_dokument (
    vorschrift,
    typ
)

SELECT
    dokument_ch.t_id,
    geobasisdaten_typ.t_id
FROM
    arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument
    LEFT JOIN
        arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche
        ON nutzungsplanung_typ_ueberlagernd_flaeche.t_id = nutzungsplanung_typ_ueberlagernd_flaeche_dokument.typ_ueberlagernd_flaeche
    LEFT JOIN
        arp_npl.rechtsvorschrften_dokument AS dokument_so
        ON dokument_so.t_id = nutzungsplanung_typ_ueberlagernd_flaeche_dokument.dokument
    LEFT JOIN
        arp_laermempfindlichkeit_mgdm.rechtsvorschrften_dokument AS dokument_ch
        ON 
            (
                dokument_so.titel = dokument_ch.titel
                AND 
                dokument_so.offiziellertitel IS NULL
                AND
                dokument_ch.offiziellertitel IS NULL
                AND
                dokument_so.publiziertab = dokument_ch.publiziertab
            )
            OR
            (
                dokument_so.titel = dokument_ch.titel
                AND 
                dokument_so.offiziellertitel = dokument_ch.offiziellertitel
                AND
                dokument_so.publiziertab = dokument_ch.publiziertab
            )
    LEFT JOIN 
        arp_laermempfindlichkeit_mgdm.geobasisdaten_typ
        ON geobasisdaten_typ.code = nutzungsplanung_typ_ueberlagernd_flaeche.code_kommunal
WHERE
    CAST(substring(code_kommunal FROM 1 FOR 3) AS integer) IN (680, 681, 682, 683, 684, 685, 686)
;