with 
orig_dataset as (
    select
        t_id  as dataset  
    from 
        afu_naturgefahren_v1.t_ili2db_dataset
    where 
        datasetname = ${kennung}
),

orig_basket as (
    select 
        basket.attachmentkey,
        basket.t_id 
    from 
        afu_naturgefahren_v1.t_ili2db_basket basket,
        orig_dataset
    where 
        basket.dataset = orig_dataset.dataset
        and 
        topic like '%Befunde'
),

basket as (
     select 
         t_id 
     from 
         afu_naturgefahren_staging_v1.t_ili2db_basket
), 

hauptprozess_sturz as ( 
    SELECT
        gefahrenstufe, 
	    charakterisierung, 
	    (st_dump(geometrie)).geom as geometrie	
	FROM 
	    afu_naturgefahren_staging_v1.gefahrengebiet_teilprozess_stein_block_fels_bergsturz 
    where 
	    datenherkunft = 'Neudaten'
),

hauptprozess_sturz_clean as (
    SELECT 
	    gefahrenstufe, 
		charakterisierung, 
		geometrie 
	FROM 
	    hauptprozess_sturz 
	WHERE 
        st_area(geometrie) > 0.001
),

hauptprozess_sturz_clean_prio as (
    SELECT 
	    gefahrenstufe, 
		charakterisierung, 
		geometrie,
		CASE 
		    WHEN gefahrenstufe = 'restgefaehrdung' THEN 0 
		    WHEN gefahrenstufe = 'gering' THEN 1 
		    WHEN gefahrenstufe = 'mittel' THEN 2 
		    WHEN gefahrenstufe = 'erheblich' THEN 3
		END as prio 
	FROM 
        hauptprozess_sturz_clean
),

hauptprozess_sturz_clean_prio_clip as (
    SELECT 
	    a.gefahrenstufe, 
		a.charakterisierung, 
		ST_Multi(COALESCE(
            ST_Difference(a.geometrie, blade.geometrie),
            a.geometrie
        )) AS geometrie
    FROM  
        hauptprozess_sturz_clean_prio AS a
    CROSS JOIN LATERAL (
        SELECT 
            ST_Union(geometrie) AS geometrie
        FROM   
            hauptprozess_sturz_clean_prio AS b
        WHERE 
            a.geometrie && b.geometrie 
            and 
            a.prio < b.prio              
    ) AS blade		
),
	
hauptprozess_sturz_point_on_polygons as (
    select 
	    gefahrenstufe,
		charakterisierung, 
		st_pointOnSurface((st_dump(geometrie)).geom) as punkt_geometrie 
	FROM 
	    hauptprozess_sturz_clean_prio_clip
),

hauptprozess_sturz_geometrie_union as (
    select 
        gefahrenstufe, 
        st_union(geometrie) as geometrie 
    from 
        hauptprozess_sturz_clean_prio_clip
    GROUP by 
        gefahrenstufe
),

hauptprozess_sturz_geometrie_split as (
    select 
        gefahrenstufe, 
        (st_dump(geometrie)).geom as geometrie 
    from 
        hauptprozess_sturz_geometrie_union
),

hauptprozess_sturz_charakterisierung_agg as (
    select 
        polygone.gefahrenstufe,
        string_agg(distinct point.charakterisierung,' ') as charakterisierung,
	    polygone.geometrie
	FROM 
	    hauptprozess_sturz_geometrie_split polygone 
    LEFT JOIN 
	    hauptprozess_sturz_point_on_polygons point 
		ON 
		ST_Dwithin(point.punkt_geometrie, polygone.geometrie,0)
	group by 
	    polygone.geometrie, 
	    polygone.gefahrenstufe
)

select 
    basket.t_id as t_basket,
    'sturz' as hauptprozess,
    gefahrenstufe,
    charakterisierung,
    st_multi(geometrie) as geometrie,
    'Neudaten' as datenherkunft, 
    orig_basket.attachmentkey as auftrag_neudaten   
from 
    basket,
    orig_basket,
    hauptprozess_sturz_charakterisierung_agg
WHERE 
    st_area(geometrie) > 0.001 
    and 
    charakterisierung is not null 