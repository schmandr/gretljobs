SELECT
    t_id,
    t_ili_tid,
    bezirksnummer,
    bezirksname,
    kanton,
    land,
    datum_aenderung,
    geometrie
FROM
    agi_swissboundaries3d_pub.swissboundaries3d_bezirk
;