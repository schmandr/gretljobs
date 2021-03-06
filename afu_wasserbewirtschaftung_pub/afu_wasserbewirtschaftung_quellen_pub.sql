(SELECT 
    TRUE AS gefasst,
    b.besitzer AS eigentuemer, 
    a.min_schuettung, 
    a.max_schuettung,
    coalesce(a.schutzzone,FALSE) AS schutzzone, 
    CASE 
        WHEN a.nutzungsart_schutzzone = 3 
        THEN 'privat'
        WHEN a.nutzungsart_schutzzone = 2 
        THEN 'privat_oeffentliches_Interesse'
        WHEN a.nutzungsart_schutzzone = 1 
        THEN 'oeffentlich'
    END AS nutzungstyp, 
    CASE 
        WHEN a.verwendung = 1 
        THEN 'Trinkwasser' 
        WHEN a.verwendung = 2 
        THEN 'Brauchwasser'
        WHEN a.verwendung = 3
        THEN 'Notbrunnen'
    END AS verwendungszweck,
    CASE 
        WHEN a.nutzungsart_schutzzone = 3
        THEN 'Private, gefasste Quelle'
        WHEN a.nutzungsart_schutzzone = 2
        THEN 'Private, gefasste Quelle von öffentlichem Interesse'
        WHEN a.nutzungsart_schutzzone = 1
        THEN 'Öffentliche, gefasste Quelle'
        WHEN a.nutzungsart_schutzzone IS NULL OR a.nutzungsart_schutzzone > 3 
        THEN 'Gefasste Quelle'
    END AS objekttyp_anzeige,
    a.bezeichnung AS objektname, 
    a.mobj_id AS objektnummer,
    a.beschreibung AS technische_angabe,
    a.bemerkung AS bemerkung,
    array_to_json(c.dokumente) AS dokumente, 
    a.wkb_geometry AS geometrie
FROM 
    vegas.obj_quelle_gefasst a 
LEFT JOIN 
    gaso.gso_mobj b ON a.mobj_id = b.mobj_id
LEFT JOIN 
    (SELECT 
         array_agg('https://geo.so.ch/docs/ch.so.afu.grundwasserbewirtschaftung/'||y.vegas_id||'_'||x.dokument_id||'.'||x.dateiendung) AS dokumente, 
         y.vegas_id
     FROM 
         vegas.adm_dokument x, 
         vegas.adm_objekt_dokument y 
     WHERE x.dokument_id = y.dokument_id
     GROUP BY y.vegas_id) c ON a.vegas_id = c.vegas_id
)
UNION ALL 
(SELECT 
    FALSE AS gefasst, 
    b.besitzer AS eigentuemer, 
    a.min_schuettung, 
    a.max_schuettung, 
    coalesce(a.schutzzone, FALSE) AS schutzzone,
    NULL AS nutzungstyp, --Die nicht gefassten Quellen werden logischerweise auch nicht genutzt. 
    NULL AS verwendungszweck, --Nicht gefasste Quellen werden nicht verwendet. 
    'ungefasste Quelle' AS objekttyp_anzeige,
    a.bezeichnung AS objektname, 
    a.mobj_id AS objektnummer, 
    a.beschreibung AS technische_angabe,
    a.bemerkung AS bemerkung, 
    array_to_json(c.dokumente) AS dokumente, 
    a.wkb_geometry AS geometrie
 FROM 
    vegas.obj_quelle a
 LEFT JOIN 
    gaso.gso_mobj b ON a.mobj_id = b.mobj_id
LEFT JOIN 
    (SELECT 
         array_agg('https://geo.so.ch/docs/ch.so.afu.grundwasserbewirtschaftung/'||y.vegas_id||'_'||x.dokument_id||'.'||x.dateiendung) AS dokumente, 
         y.vegas_id
     FROM 
         vegas.adm_dokument x, 
         vegas.adm_objekt_dokument y 
     WHERE x.dokument_id = y.dokument_id
     GROUP BY y.vegas_id) c ON a.vegas_id = c.vegas_id
);
