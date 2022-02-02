DROP TABLE IF EXISTS 
    alw_fruchtfolgeflaechen.fff_maske_where_bodenkartierung
;

WITH bodenbedeckung AS (
    SELECT 
        ST_CollectionExtract(ST_makevalid(ST_snaptogrid(ST_union(geometrie),0.001)),3) AS geometrie
    FROM 
        afu_isboden_pub.bodeneinheit
)

SELECT 
    ST_intersection(maske.geometrie, bodenbedeckung.geometrie,0.001) AS geometrie
INTO 
    alw_fruchtfolgeflaechen.fff_maske_where_bodenkartierung
FROM 
    alw_fruchtfolgeflaechen.fff_maske_fertig maske, 
    bodenbedeckung 
WHERE 
    ST_intersects(maske.geometrie,bodenbedeckung.geometrie)
;

-- GeometryCollections werden aufgelöst. Nur die Polygons werden herausgenommen.
UPDATE 
    alw_fruchtfolgeflaechen.fff_maske_where_bodenkartierung
    SET 
    geometrie = ST_CollectionExtract(geometrie, 3)
WHERE 
    ST_geometrytype(geometrie) = 'ST_GeometryCollection'
;

DELETE FROM 
    alw_fruchtfolgeflaechen.fff_maske_where_bodenkartierung
WHERE 
    ST_IsEmpty(geometrie)
;

CREATE INDEX IF NOT EXISTS
    fff_maske_where_bodenkartierung_geometrie_idx 
    ON 
    alw_fruchtfolgeflaechen.fff_maske_where_bodenkartierung
USING GIST(geometrie)
;
