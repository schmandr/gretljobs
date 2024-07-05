DELETE FROM 
    ${DB_SCHEMA}.gebaeude_gebaeude_proj
;

WITH gebaeudename AS (
    SELECT 
        objektname.objektname,
        bodenbedeckung.t_id
    FROM agi_mopublic_pub.mopublic_objektname_pos AS objektname
        JOIN agi_mopublic_pub.mopublic_bodenbedeckung_proj AS bodenbedeckung
        ON ST_Contains(bodenbedeckung.geometrie , objektname.pos)
    WHERE objektname.art_txt = 'Gebaeude' AND objektname.herkunft = 'BB'
)
INSERT INTO 
    ${DB_SCHEMA}.gebaeude_gebaeude_proj
    (
        bfs_nr,
        geometrie,
        egid,
        gebaeudename,
        gebaeudeeingang,
        link_gwr
    )
(
    SELECT
        bodenbedeckung.bfs_nr,
        bodenbedeckung.geometrie,
        bodenbedeckung.egid,
        gebaeudename.objektname AS gebaeudename,
        --json_agg(adresse.strassenname),
        json_agg(json_build_object(
            '@type', 'SO_AGI_Gebaeudeflaechen_Publikation_20240705.Gebaeude.Gebaeudeeingang',
            'Strassenname', adresse.strassenname, 
            'Hausnummer', adresse.hausnummer,
            'PLZ', adresse.plz,
            'Ortschaft', adresse.ortschaft,
            'EDID', adresse.edid,
            'ist_offizielle_Bezeichung', adresse.ist_offizielle_bezeichnung,
            'Hoehenlage', adresse.hoehenlage,
            'Status', adresse.astatus
        )) AS gebaeudeeingang,
        CASE
            WHEN bodenbedeckung.egid IS NOT NULL
                THEN concat('https://www.housing-stat.ch/de/query/egid.html?egid=',bodenbedeckung.egid::TEXT)
            ELSE 'https://www.housing-stat.ch/'
        END AS link_gwr
    FROM 
        agi_mopublic_pub.mopublic_gebaeudeadresse AS adresse
        JOIN agi_mopublic_pub.mopublic_bodenbedeckung_proj AS bodenbedeckung
        ON ST_Contains(bodenbedeckung.geometrie, adresse.lage)
        LEFT JOIN gebaeudename AS gebaeudename 
        ON gebaeudename.t_id = bodenbedeckung.t_id 
    WHERE 
        bodenbedeckung.art_txt = 'Gebaeude'
    GROUP BY 
        bodenbedeckung.egid, bodenbedeckung.bfs_nr, bodenbedeckung.geometrie, gebaeudename.objektname
)
;
