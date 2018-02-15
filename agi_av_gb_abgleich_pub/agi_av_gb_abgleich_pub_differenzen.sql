SELECT
    ogc_fid AS t_id,
    geometrie,
    av_gem_bfs,
    av_nbident,
    av_gemeinde,
    av_nummer,
    av_art,
    av_art_txt,
    av_flaeche,
    av_lieferdatum,
    av_mutation_id,
    av_mut_beschreibung,
    gb_gem_bfs,
    gb_kreis_nr,
    gb_gemeinde,
    gb_nummer,
    gb_art,
    gb_flaeche,
    gb_fuehrungsart,
    gb_nbident,
    flaechen_differenz,
    fehlerart 
FROM
    av_gb_abgleich.differenzen
;