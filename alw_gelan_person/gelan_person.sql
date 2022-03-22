select 
    pid_gelan as pid_15, 
    bfs_nummer_wohnsitz as gid,
    gemeinde_wohnsitz as gid_name,
    name_vorname as name_vorname,
    aname as name, 
    name_trennzeichen as name_trenner, 
    zweitname as zweitname,
    vorname as vorname,
    adresse_strasse as adresse,
    adresse_hausnummer as adr_nr,
    postfachnummer as pf_nr,
    plz as plz,
    ortschaft as ort,
    anrede as anrede,
    briefanrede as briefanr,
    sprache as sprache,
    telefon_privat as tel_p,
    telefon_geschaeft as tel_g,
    telefon_mobil as mobile,
    mailadresse as email,
    geburtsdatum as geb_datum,
    enddatum as ende_dat,
    sozialversicherungsnummer as nvn, 
    personen_typ as pers_typ,
    rechtsform as rechtsform,
    typ_zahlverbindung as typ_zahlverbindung,
    bank as bank,
    clearing as clearing,
    bankkonto as bkto,
    postkonto as pckto,
    CASE 
        WHEN iban IS NULL 
        THEN '' 
        ELSE iban 
    END as iban,
    prueftext_iban as text_iban,
    pid_beguenstigter as pid_beguenstigter,
    beguenstigter as beguenstigter
from 
    alw_landwirtschaft_tierhaltung_v1.betrbsdttrktrdten_gelan_person bgp 
