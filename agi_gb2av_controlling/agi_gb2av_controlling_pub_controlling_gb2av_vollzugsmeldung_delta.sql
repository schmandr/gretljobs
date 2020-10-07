SELECT 
    t_ili_tid,
    mutationsnummer,
    nbident,
    delta,
    gb_status,
    gb_bemerkungen,
    gb_grundbucheintrag,
    gb_tagebucheintrag,
    gb_tagebuchbeleg,
    av_beschreibung,
    av_gueltigkeit,
    av_gueltigereintrag,
    av_gbeintrag,
    av_firma,
    datasetname,
    perimeter,
    grundstuecksart
FROM 
    agi_gb2av_controlling.controlling_gb2av_vollzugsmeldung_delta
;