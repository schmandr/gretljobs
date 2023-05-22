INSERT
   INTO ${DB_Schema_MJPNL}.mjpnl_beurteilung_hecke
     (
       --ignored: t_id 
       t_basket,
       --ignored: t_ili_tid
       einstiegskriterium_lage,
       einstiegskriterium_mindestdimension_gehoelz_krautsaum,
       einstiegskriterium_unterhalteingriffe_abgesprochen,
       einstiegskriterium_verzichtdiversegeraete,
       einstiegskriterium_verzichthilfsstoffe,
       einstiegskriterium_keineinsatzwieseneggenstriegelwalzen,
       einstiegskriterium_bff_stufe_i_ii_erfuellt,
       einstiegskriterium_abgeltung_ha,
       faunabonus_anzahl_arten,
       faunabonus_artenvielfalt_abgeltung_pauschal,
       einstufungbeurteilungistzustand_artenvielfalt_strauch_bmrten,
       einstufungbeurteilungistzustand_asthaufen,
       einstufungbeurteilungistzustand_totholz,
       einstufungbeurteilungistzustand_steinhaufen,
       einstufungbeurteilungistzustand_schichtholzbeigen,
       einstufungbeurteilungistzustand_nisthilfe_wildbienen,
       einstufungbeurteilungistzustand_hoehlenbaeume_biotpbm_ttholz,
       einstufungbeurteilungistzustand_sitzwarte,
       einstufungbeurteilungistzustand_abgeltung_ha,
       --ignored: bewirtschaftung_hecke_typ_niederhecke,
       --ignored: bewirtschaftung_hecke_typ_hochhecke,
       --ignored: bewirtschaftung_hecke_typ_baumhecke,
       --ignored: bewirtschaftung_hecke_typ_lebhag,
       --ignored: bewirtschaftung_hecke_unterhalt,
       --ignored: bewirtschaftung_hecke_unterhaltsintervall,
       bewirtschaftung_hecke_letzterunterhalt,
       --ignored: bewirtschaftung_hecke_unterhaltanteil,
       bewirtschaftung_krautsaum,
       bewirtschaftung_krautsaum_schnittzeitpunkte,
       --ignored: bewirtschaftung_krautsaum_schnittzeitpunkt_1,
       --ignored: bewirtschaftung_krautsaum_schnittzeitpunkt_2,
       bewirtschaftung_krautsaum_offener_boden,
       bewirtschaftung_krautsaum_keine_beweidung,
       bewirtschaftung_krautsaum_beweidung_nach_absprache,
       bewirtschaftung_krautsaum_abgeltung_ha,
       bewirtschaftung_lebhag_laufmeter,
       --ignored: bewirtschaftung_lebhag_abgeltung_pauschal,
       erschwernis_massnahme1,
       --ignored: erschwernis_massnahme1_text ,
       erschwernis_massnahme1_abgeltung_ha,
       erschwernis_massnahme2,
       --ignored: erschwernis_massnahme2_text,
       erschwernis_massnahme2_abgeltung_ha,
       erschwernis_massnahme3,
       --ignored: erschwernis_massnahme3_text,
       erschwernis_massnahme3_abgeltung_ha,
       erschwernis_abgeltung_ha,
       beurteilungsdatum,
       bemerkungen,
       kopie_an_bewirtschafter,
       mit_bewirtschafter_besprochen,
       --ignored: datum_besprechung_bewirtschafter
       abgeltung_per_ha_total,
       abgeltung_flaeche_total,
       abgeltung_pauschal_total,
       --ignored: abgeltung_generisch_text
       --ignored: abgeltung_generisch_betrag
       abgeltung_total,
       --ignored: besondere_abmachungen
       erstellungsdatum,
       operator_erstellung,
       --ignored: aenderungsdatum,
       --ignored: operator_aenderung
       berater,
       vereinbarung
     ) 
WITH tmp AS (
    SELECT
        t_id,
        t_basket,
        vereinbarungs_nr,
        flaeche,
        (string_to_array(bemerkung,'§'))[2]::jsonb AS old_attr
    FROM ${DB_Schema_MJPNL}.mjpnl_vereinbarung
        WHERE ( vereinbarungsart = 'Hecke' OR vereinbarungsart = 'Lebhag' ) AND vereinbarungs_nr != '01_DUMMY_00001'
)
SELECT
   t_basket,
   TRUE AS einstiegskriterium_lage,
   TRUE AS einstiegskriterium_mindestdimension_gehoelz_krautsaum,
   TRUE AS einstiegskriterium_unterhalteingriffe_abgesprochen,
   TRUE AS einstiegskriterium_verzichtdiversegeraete,
   TRUE AS einstiegskriterium_verzichthilfsstoffe,
   TRUE AS einstiegskriterium_keineinsatzwieseneggenstriegelwalzen,
   TRUE AS einstiegskriterium_bff_stufe_i_ii_erfuellt,
   0 AS einstiegskriterium_abgeltung_ha,
   0 AS faunabonus_anzahl_arten,
   0 AS faunabonus_artenvielfalt_abgeltung_pauschal,
   FALSE AS einstufungbeurteilungistzustand_artenvielfalt_strauch_bmrten,
   FALSE AS einstufungbeurteilungistzustand_asthaufen,
   FALSE AS einstufungbeurteilungistzustand_totholz,
   FALSE AS einstufungbeurteilungistzustand_steinhaufen,
   FALSE AS einstufungbeurteilungistzustand_schichtholzbeigen,
   FALSE AS einstufungbeurteilungistzustand_nisthilfe_wildbienen,
   FALSE AS einstufungbeurteilungistzustand_hoehlenbaeume_biotpbm_ttholz,
   FALSE AS einstufungbeurteilungistzustand_sitzwarte,
   0 AS einstufungbeurteilungistzustand_abgeltung_ha,
   substring(old_attr->>'letzter_unterhalt', 0, 5)::integer AS bewirtschaftung_hecke_letzterunterhalt,
   FALSE AS bewirtschaftung_krautsaum,
   FALSE AS bewirtschaftung_krautsaum_schnittzeitpunkte,
   FALSE AS bewirtschaftung_krautsaum_offener_boden,
   FALSE AS bewirtschaftung_krautsaum_keine_beweidung,
   FALSE AS bewirtschaftung_krautsaum_beweidung_nach_absprache,
   0 AS bewirtschaftung_krautsaum_abgeltung_ha,
   (old_attr->>'hecken_laufmeter')::integer AS bewirtschaftung_lebhag_laufmeter,
   FALSE AS erschwernis_massnahme1,
   0 AS erschwernis_massnahme1_abgeltung_ha,
   FALSE AS erschwernis_massnahme2,
   0 AS erschwernis_massnahme2_abgeltung_ha,
   FALSE AS erschwernis_massnahme3,
   0 AS erschwernis_massnahme3_abgeltung_ha,
   0 AS erschwernis_abgeltung_ha,
   COALESCE( (old_attr->>'datum_beurteilung')::date, now()::date ) AS beurteilungsdatum,
   'Unvollständige Beurteilung aus Migration' AS bemerkungen,
   FALSE AS kopie_an_bewirtschafter,
   FALSE AS mit_bewirtschafter_besprochen,
   0 AS abgeltung_per_ha_total,
   -- es wird keine total abgeltung kalkuliert (da keine abgeltung per ha gesetzt ist)
   0 AS abgeltung_flaeche_total,
   0 AS abgeltung_pauschal_total,
   -- derzeit keine Pauschale berücksichtigen
   0 AS abgeltung_total,
   now()::date AS erstellungsdatum,
   'Migration' AS operator_erstellung,
   (SELECT t_id FROM ${DB_Schema_MJPNL}.mjpnl_berater WHERE aname = 'Bruggisser') AS berater,
   t_id AS vereinbarung
FROM
  tmp
;
