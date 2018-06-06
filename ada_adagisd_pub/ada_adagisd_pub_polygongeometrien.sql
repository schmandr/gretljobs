SELECT
    poly_geometrie.ogc_fid AS t_id,
    object_id,
    ST_Multi(wkb_geometry) AS geometrie,
    extent,
    "object"."name",
    poly_geometrie.uuid,
    "_area",
    "_area_old",
    overlays,
    schutzstatus,
    gemeinde,
    strasse,
    hausnummer, 
    areal
FROM
    ada_adagis_d.poly_geometrie
    LEFT JOIN ada_adagis_d."object"
    ON "object".uuid = poly_geometrie.uuid
WHERE
    poly_geometrie.archive = 0
    AND
    "object".archive = 0
;
