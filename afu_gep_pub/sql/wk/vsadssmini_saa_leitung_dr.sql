

WITH leitungen AS (
    SELECT
        l.t_ili_tid as oid_dss,
        l.t_datasetname as dataset,
        REPLACE(l.nutzungsart_ist, '_', ' ') AS nutzungsart_ist,
        REPLACE(l.nutzungsart_geplant, '_', ' ') AS nutzungsart_geplant,
        l.funktionhierarchisch,
        l.funktionhydraulisch,
        l.finanzierung,
        REPLACE(l.profiltyp, '_', ' ') AS profiltyp,
        l.astatus,
        l.verlauf,
        l.baujahr,
        CASE 
            WHEN l.baulicherzustand = 'Z0' THEN 'Z0: Nicht mehr funktionstüchtig'
            WHEN l.baulicherzustand = 'Z1' THEN 'Z1: Starke Mängel'
            WHEN l.baulicherzustand = 'Z2' THEN 'Z2: Mittlere Mängel'
            WHEN l.baulicherzustand = 'Z3' THEN 'Z3: Leichte Mängel'
            WHEN l.baulicherzustand = 'Z4' THEN 'Z4: Keine Mängel'
            ELSE l.baulicherzustand
        END AS baulicherzustand,
        l.zustandserhebung_jahr,
        l.bezeichnung,
        l.kote_von,
        l.kote_nach,
        l.lagebestimmung,
        CASE 
            WHEN l.material = 'Beton_Normalbeton' THEN 'Normalbeton'
            WHEN l.material = 'Beton_Ortsbeton' THEN 'Ortsbeton'
            WHEN l.material = 'Beton_Pressrohrbeton' THEN 'Beton'
            WHEN l.material = 'Beton_Spezialbeton' THEN 'Beton'
            WHEN l.material = 'Beton_unbekannt' THEN 'Beton'
            WHEN l.material = 'Guss_duktil' THEN 'Guss'
            WHEN l.material = 'Guss_Grauguss' THEN 'Guss'
            WHEN l.material = 'Kunstoff_Epoxyharz' THEN 'Kunststoff (EP)'
            WHEN l.material = 'Kunstoff_Hartpolyethylen' THEN 'Kunststoff (PE)'
            WHEN l.material = 'Kunststoff_Polyester_GUP' THEN 'Kunststoff (GUP)'
            WHEN l.material = 'Kunststoff_Polyethylen' THEN 'Kunststoff (PE)'
            WHEN l.material = 'Kunstoff_Polypropylen' THEN 'Kunststoff (PP)'
            WHEN l.material = 'Kunststoff_Polyvinilchlorid' THEN 'Kunststoff (PVC)'
            WHEN l.material = 'Kunststoff_unbekannt' THEN 'Kunststoff'
            WHEN l.material = 'Stahl_rostfrei' THEN 'Stahl'
            WHEN l.material = 'Steinzeug' THEN 'Steinzeug'
            ELSE REPLACE(l.material, '_', ' ')
        END AS material,
        l.laengeeffektiv,
        REPLACE(l.reliner_art, '_', ' ') AS reliner_art,
        l.hydr_belastung_ist,
        REPLACE(l.leckschutz, '_', ' ') AS leckschutz,
        l.lichte_hoehe,
        l.lichte_breite,
        eig.organisationstyp AS eigentuemer_organisationstyp,
        eig.bezeichnung AS eigentuemer_bezeichnung,
        CASE
            WHEN l.funktionhydraulisch IN ('Drainagetransportleitung', 'Sickerleitung') THEN 'L_Drainage'
        END AS stilid
    FROM
        ${DB_SCHEMA_EDIT}.vsadssmini_leitung l
        LEFT JOIN ${DB_SCHEMA_EDIT}.administration_organisation eig ON l.eigentuemerref = eig.t_id
    WHERE
        l.verlauf IS NOT NULL 
)
INSERT INTO 
    ${DB_SCHEMA_PUB_STAGING}.wk_saa_leitung_dr 
    (
        baujahr, 
        baulicherzustand, 
        bezeichnung, 
        eigentuemer_bezeichnung, 
        eigentuemer_organisationstyp, 
        finanzierung, funktionhierarchisch, 
        funktionhydraulisch, 
        laengeeffektiv, 
        lagebestimmung, 
        leckschutz, 
        lichte_breite, 
        lichte_hoehe, 
        material, 
        nutzungsart_geplant, 
        nutzungsart_ist, 
        oid_dss, 
        profiltyp, 
        reliner_art, 
        astatus, 
        verlauf, 
        dataset, 
        stilid, 
        zustandserhebung_jahr
    )
SELECT
    baujahr,
    baulicherzustand,
    bezeichnung,
    eigentuemer_bezeichnung,
    eigentuemer_organisationstyp,
    finanzierung,
    funktionhierarchisch,
    funktionhydraulisch,
    laengeeffektiv,
    lagebestimmung,
    leckschutz,
    lichte_breite,
    lichte_hoehe,
    material,
    nutzungsart_geplant,
    nutzungsart_ist,
    oid_dss,
    profiltyp,
    reliner_art,
    astatus,
    verlauf,
    dataset,
    stilid,
    zustandserhebung_jahr
FROM leitungen
WHERE astatus LIKE 'in_Betrieb%'
AND funktionhierarchisch LIKE 'SAA.%'
AND funktionhydraulisch IN ('Drainagetransportleitung', 'Sickerleitung')
AND stilid IS NOT NULL
;
