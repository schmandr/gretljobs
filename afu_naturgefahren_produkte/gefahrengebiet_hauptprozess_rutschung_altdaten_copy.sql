with
basket as (
     select 
         t_id 
     from 
         afu_naturgefahren_staging_v1.t_ili2db_basket
), 

attribute_mapping_hangmure as (
    SELECT 
        basket.t_id as t_basket,
        'rutschung' as hauptprozess, 
        case 
        	when gef_stufe = 'vorhanden' then 'restgefaehrdung'
        	when gef_stufe = 'gering' then 'gering'
        	when gef_stufe = 'mittel' then 'mittel' 
        	when gef_stufe = 'erheblich' then 'erheblich'
        end as gefahrenstufe, 
        replace(aindex, '_', '') as charakterisierung, 
        st_multi(geometrie) as geometrie, --Im neuen Modell sind Multi-Polygone
        'Altdaten' as datenherkunft, 
        null as auftrag_neudaten
    FROM 
        afu_gefahrenkartierung.gefahrenkartirung_gk_hangmure, 
        basket
    where 
        publiziert = true 
        and 
        gef_stufe != 'keine'
), 

attribute_mapping_plo_rutschung as (
    SELECT 
        basket.t_id as t_basket,
        'rutschung' as hauptprozess,
        case 
        	when gef_stufe = 'vorhanden' then 'restgefaehrdung'
        	when gef_stufe = 'gering' then 'gering'
        	when gef_stufe = 'mittel' then 'mittel' 
        	when gef_stufe = 'erheblich' then 'erheblich'
        end as gefahrenstufe, 
        replace(aindex, '_', '') as charakterisierung, 
        st_multi(geometrie) as geometrie, --Im neuen Modell sind Multi-Polygone
        'Altdaten' as datenherkunft, 
        null as auftrag_neudaten
    FROM 
        afu_gefahrenkartierung.gefahrenkartirung_gk_rutsch_spontan,
        basket
    where 
        publiziert = true 
        and 
        gef_stufe != 'keine'
),

attribute_mapping_perm_rutschung as (
    SELECT 
        basket.t_id as t_basket,
        'rutschung' as hauptprozess,
        case 
        	when gef_stufe = 'vorhanden' then 'restgefaehrdung'
        	when gef_stufe = 'gering' then 'gering'
        	when gef_stufe = 'mittel' then 'mittel' 
        	when gef_stufe = 'erheblich' then 'erheblich'
        end as gefahrenstufe, 
        replace(aindex, '_', '') as charakterisierung, 
        st_multi(geometrie) as geometrie, --Im neuen Modell sind Multi-Polygone
        'Altdaten' as datenherkunft, 
        null as auftrag_neudaten
    FROM 
        afu_gefahrenkartierung.gefahrenkartirung_gk_rutsch_kont_sackung,
        basket
    where 
        publiziert = true 
        and 
        gef_stufe != 'keine'
)

INSERT INTO afu_naturgefahren_staging_v1.gefahrengebiet_hauptprozess_rutschung (
    t_basket, 
    hauptprozess, 
    gefahrenstufe, 
    charakterisierung, 
    geometrie, 
    datenherkunft, 
    auftrag_neudaten
)

    select * from attribute_mapping_hangmure
    union all 
    select * from attribute_mapping_plo_rutschung
    union all 
    select * from attribute_mapping_perm_rutschung






