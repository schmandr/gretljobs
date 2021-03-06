-- Summe ungewichtete Abfahrten pro Haltestelle und Linie 
DELETE FROM avt_oevkov_${currentYear}.auswertung_auswertung_gtfs
;

INSERT INTO
    avt_oevkov_${currentYear}.auswertung_auswertung_gtfs
    (
    haltestellenname,
    linie,
    unternehmer,
    anzahl_abfahrten_linie,
    verkehrsmittel
    )
    (
-- Diesen Block bis unten kopieren und in SQL abfahrten_oev_guete.sql einfügen
-- *******************************************************************************
    WITH calendar AS (
        SELECT
            service_id,
        CASE
        WHEN (SELECT BTRIM(lower(to_char((
                         SELECT
                                 stichtag
                             FROM
                                    avt_oevkov_${currentYear}.sachdaten_oevkov_daten), 'Day')))) = 'thursday'
             THEN thursday
        WHEN (SELECT BTRIM(lower(to_char((
                         SELECT
                                 stichtag
                             FROM
                                    avt_oevkov_${currentYear}.sachdaten_oevkov_daten), 'Day')))) = 'tuesday'
             THEN tuesday
        END AS dayofweek
        FROM
            avt_oevkov_${currentYear}.gtfs_calendar
    ),
    exception AS (
        SELECT
            service_id,
            exception_type
        FROM
            avt_oevkov_${currentYear}.gtfs_calendar_dates
        WHERE
            datum = (
                            SELECT
                                stichtag
                            FROM
                                avt_oevkov_${currentYear}.sachdaten_oevkov_daten)
    ),
    abfahrten AS (
        SELECT
            stop.stop_name,
            linie.linienname,
            agency.agency_id,
            agency.unternehmer,
            route.route_id,
            route.route_type,
            route.route_desc,
            trip.trip_id,
            trip.trip_headsign,
            stoptime.pickup_type,
            count(departure_time) AS gtfs_count,         
            CASE
                WHEN route_desc = 'Bus'                                                               
                     THEN 1
                WHEN route_desc IN ('RegioExpress', 'InterRegio', 'Intercity')
                     THEN 2
                WHEN route_desc IN ('Regionalzug', 'S-Bahn', 'Tram')
                    THEN 3
            END AS verkehrsmittel
        FROM
            avt_oevkov_${currentYear}.gtfs_agency AS agency, 
            avt_oevkov_${currentYear}.gtfs_route AS route,
            avt_oevkov_${currentYear}.gtfs_trip AS trip,
            avt_oevkov_${currentYear}.gtfs_stoptime AS stoptime,
            avt_oevkov_${currentYear}.gtfs_stop AS stop,
            avt_oevkov_${currentYear}.sachdaten_linie_route AS linie 
        WHERE
            (
            trip.service_id IN (
                SELECT
                    service_id
                FROM
                    calendar
                WHERE dayofweek = 1
            )
            OR
            trip.service_id IN (
                SELECT
                    service_id
                FROM
                    exception
                WHERE
                    exception_type = 1
             )
        )
        AND
            trip.service_id NOT IN (
                SELECT
                    service_id
                FROM
                    exception
                WHERE
                    exception_type = 2
        )
        AND
-- diese Haltestellen werden nur wegen Spezialfall Bahnhof Olten benötigt
            stop.stop_name NOT IN (
                'Aarau',
                'Langenthal',
                'Zofingen'
            )
        AND
            agency.agency_id::text = route.agency_id
        AND
            route.route_id = trip.route_id
        AND
            route.route_id = linie.route_id
        AND
            stop.stop_id = stoptime.stop_id
        AND
            stoptime.trip_id = trip.trip_id
--         AND
--             trip_headsign <> stop.stop_name
        AND
            pickup_type = 0
        AND
           route_desc IN (
               'Intercity',
               'ICE',
               'InterRegio',
               'RegioExpress',
               'Regionalzug',
               'S-Bahn',
               'Bus',
               'Tram'
           )
/*
-- ***************** zusätzliche Bedingung für OeV-Güteklassen *****************
        AND
            substring(departure_time from 1 for 2) IN
                ('06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19')
-- *******************************************************************************
*/
        GROUP BY
            stop.stop_name,
            linie.linienname,
            agency.agency_id,
            agency.unternehmer,
            route.route_id,
            route.route_type,
            route_desc,
            trip.trip_id,
            trip_headsign,
            pickup_type,
            verkehrsmittel
    )
 

-- die meisten Haltestellen
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count) AS gtfs_count,
        verkehrsmittel
    FROM
        abfahrten
    WHERE
       trip_headsign <> stop_name
       
-- *********** hier kommen die Ausnahmen, die werden unten abgehandelt ***********
    
-- gewisse Bahnhöfe werden separat behandelt wegen Zuordnung zu den LInien
       AND
           stop_name NOT IN (
              'Däniken',
              'Dornach-Arlesheim',
              'Dulliken',
              'Flüh, Bahnhof',
              'Grenchen Nord',
               'Grenchen Süd',
              'Murgenthal',
              'Olten',
              'Schönenwerd SO',
              'Solothurn'
        )
    -- ***************************** Ende der Ausnahmen *********************************

    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

--  Alle Haltestellen ergänzen,welche ausserhalb des Kantons liegen, aber einer
--  Solothurner Gemeinde angerechnet werden, ausser die, welche unten als Speziallfall
--  behandelt werden. Die Zuordnung zu einer Gemeinde erfolgt über die Tabelle
--  avt_oevkov_${currentYear}.sachdaten_haltestelle_anrechnung, welche
--  durch die Abt. OeV festgelegt wird
    SELECT  
        stop.stop_name,
        linie.linienname,
        agency.unternehmer,
        count(departure_time) AS gtfs_count,
        CASE
            WHEN route_desc= 'Bus'
                 THEN 1 
            WHEN route_desc IN ('RegioExpress', 'InterRegio', 'Intercity')
                 THEN 2
            WHEN route_desc IN ('Regionalzug', 'S-Bahn',  'Tram')
                THEN 3
        END AS verkehrsmittel
    FROM avt_oevkov_${currentYear}.gtfs_agency AS agency,
        avt_oevkov_${currentYear}.gtfs_route AS route,
        avt_oevkov_${currentYear}.gtfs_trip AS trip,
        avt_oevkov_${currentYear}.gtfs_stoptime AS stoptime,
        avt_oevkov_${currentYear}.gtfs_stop AS stop,
        avt_oevkov_${currentYear}.sachdaten_linie_route AS linie
    WHERE
        (
        trip.service_id IN (
            SELECT
                service_id
            FROM
                calendar
            WHERE dayofweek = 1
            )
        OR
        trip.service_id IN (
            SELECT
                service_id
            FROM
                exception
            WHERE
                exception_type = 1
            )
        )
    AND
        trip.service_id NOT IN (
            SELECT
                service_id
            FROM
                exception
            WHERE
                exception_type = 2
    )
    AND
        stop.stop_name IN (
            'Arlesheim, Obesunne',
            'Erlinsbach, Oberdorf',
            'Erlinsbach, Sagi',
            'Gänsbrunnen',
            'Gänsbrunnen, Bahnhof',
            'Nuglar, Neunuglar', 
            'Niederbipp Industrie',
            'Walterswil-Striegel'
         )
    AND
        agency.agency_id::text = route.agency_id 
    AND
        route.route_id = trip.route_id
    AND
        route.route_id = linie.route_id 
    AND
        stop.stop_id = stoptime.stop_id
    AND
        stoptime.trip_id = trip.trip_id
    AND
        trip_headsign <> stop.stop_name
    AND
        pickup_type = 0
    AND
       route_desc IN (
           'Intercity',
           'ICE',
           'InterRegio',
           'RegioExpress',
           'Regionalzug',
           'S-Bahn',
           'Bus',
           'Tram'
       )
    GROUP BY
        stop.stop_name,
        linie.linienname,
        agency.unternehmer,
        verkehrsmittel

-- **************************************************************************************
-- ab hier werden die Bahnhöfe und andere Knotenpunkte behandelt,
-- wegen Aufteilung in Linien des OEVKOV

    UNION ALL
    
-- Bahnhof Solothurn
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
       trip_headsign <> stop_name
    AND
        stop_name = 'Solothurn'
    AND
        substring(linienname from 1 for 4) IN
            ('L304', 'L308', 'L410', 'L411', 'L413')
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

UNION ALL

--   Bahnhof Olten: L410 Biel - Olten
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count) AS gtfs_count,
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Olten'
    AND
         trip_headsign IN (
             'Biel/Bienne',
             'Genève-Aéroport',
             'Langendorf',
             'Lausanne',
             'Lommiswil',
             'Oensingen',
             'Solothurn'
         )
    AND
        linienname LIKE 'L410%'
     AND
        trip_id IN (
            SELECT
                trip_einschraenkung.trip_id
            FROM
                avt_oevkov_${currentYear}.gtfs_route AS route_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_trip AS trip_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stop AS stop_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stoptime AS stoptime_einschraenkung
           WHERE
               (trip_einschraenkung.service_id IN (
                SELECT
                    service_id
                FROM
                    calendar
                WHERE dayofweek = 1
               )
               OR
                   trip_einschraenkung.service_id IN (
                    SELECT
                        service_id
                    FROM
                        exception
                    WHERE
                        exception_type = 1
                         )
                )
            AND
                trip_einschraenkung.service_id NOT IN (
                SELECT
                    service_id
                FROM
                    exception
                WHERE
                    exception_type = 2
                )
             AND
                stop_einschraenkung.stop_name IN ('Solothurn', 'Oensingen')
             AND
                route_einschraenkung.route_id = trip_einschraenkung.route_id
             AND
                stop_einschraenkung.stop_id = stoptime_einschraenkung.stop_id
             AND
                stoptime_einschraenkung.trip_id = trip_einschraenkung.trip_id
         )
    GROUP BY
        stop_name,
        linienname,
        gtfs_count,
        unternehmer,
        verkehrsmittel

UNION ALL

-- Bahnhof Olten:  L450 Olten - Bern
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Olten'
    AND
        trip_headsign IN ('Bern', 'Langenthal')
    AND
        linienname LIKE 'L450%'
    AND
        trip_id IN (
            SELECT
                trip_einschraenkung.trip_id
            FROM
                avt_oevkov_${currentYear}.gtfs_route AS route_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_trip AS trip_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stop AS stop_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stoptime AS stoptime_einschraenkung
           WHERE
               (
               trip_einschraenkung.service_id IN (
                SELECT
                    service_id
                FROM
                    calendar
                WHERE dayofweek = 1
               )
               OR
                   trip_einschraenkung.service_id IN (
                    SELECT
                        service_id
                    FROM
                        exception
                    WHERE
                        exception_type = 1
                     )
                )
            AND
                trip_einschraenkung.service_id NOT IN (
                SELECT
                    service_id
                FROM
                    exception
                WHERE
                    exception_type = 2
                    )
                 AND
                    stop_einschraenkung.stop_name IN ('Langenthal')
                 AND
                    route_einschraenkung.route_id = trip_einschraenkung.route_id
                 AND
                    stop_einschraenkung.stop_id = stoptime_einschraenkung.stop_id
                 AND
                    stoptime_einschraenkung.trip_id = trip_einschraenkung.trip_id
         )
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof Olten: L500 Olten - Basel (S3)
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Olten'
    AND
       linienname = 'L500 Olten - Basel (S3)'
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof Olten: L503 Olten - Sissach (S9)
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Olten'
    AND
        linienname = 'L503 Olten - Sissach (S9)'
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof Olten: L510 Olten - Sursee (S8)
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Olten'
    AND
        linienname = 'L510 Olten - Sursee (S8)'
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof Olten: L510 Olten - Luzern (IR/RE), RegioExpress zählt hier zu R
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Olten'
    AND
        trip_headsign = 'Luzern'
    AND
        substring(linienname from 1 for 4) = 'L510'
    AND
        route_desc IN ('RegioExpress', 'InterRegio')
    AND
        trip_id IN (
            SELECT
                trip_einschraenkung.trip_id 
            FROM 
                avt_oevkov_${currentYear}.gtfs_route AS route_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_trip AS trip_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stop AS stop_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stoptime AS stoptime_einschraenkung
            WHERE
                (
                trip_einschraenkung.service_id IN (
                SELECT
                    service_id
                FROM
                    calendar
                WHERE dayofweek = 1
               )
               OR trip_einschraenkung.service_id IN (
                SELECT
                    service_id
                FROM
                    exception
                WHERE
                    exception_type = 1
                 )
            )
        AND
            trip_einschraenkung.service_id NOT IN (
            SELECT
                service_id
            FROM
                exception
            WHERE
                exception_type = 2
            )
             AND
                stop_einschraenkung.stop_name = 'Zofingen'
             AND
                trip_einschraenkung.trip_headsign <> 'Olten'
             AND
                 trip_headsign = 'Luzern'
             AND
                route_einschraenkung.route_id = trip_einschraenkung.route_id
             AND
                stop_einschraenkung.stop_id = stoptime_einschraenkung.stop_id
             AND
                stoptime_einschraenkung.trip_id = trip_einschraenkung.trip_id
             AND
                route_desc IN ('RegioExpress', 'InterRegio')
         )
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

     UNION ALL

-- Bahnhof Olten: L650 Olten - Zürich HB (IC/IR/RE)
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Olten'
    AND
        trip_headsign IN (
            'Baden',
            'Romanshorn',
            'Rotkreuz',
            'St. Gallen',
            'Turgi',
            'Wettingen',
            'Zürich Flughafen',
            'Zürich HB'
        )
    AND
        linienname LIKE 'L650%'
    AND
        trip_id IN (
            SELECT
                trip_einschraenkung.trip_id 
            FROM 
                avt_oevkov_${currentYear}.gtfs_route AS route_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_trip AS trip_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stop AS stop_einschraenkung,
                avt_oevkov_${currentYear}.gtfs_stoptime AS stoptime_einschraenkung
              WHERE
                (
                trip_einschraenkung.service_id IN (
            SELECT
                service_id
            FROM
                calendar
            WHERE dayofweek = 1
           )
           OR trip_einschraenkung.service_id IN (
            SELECT
                service_id
            FROM
                exception
            WHERE
                exception_type = 1
                 )
            )
        AND
            trip_einschraenkung.service_id NOT IN (
            SELECT
                service_id
            FROM
                exception
            WHERE
                exception_type = 2
            )
            AND
                stop_einschraenkung.stop_name = 'Aarau'
            AND
                route_einschraenkung.route_id = trip_einschraenkung.route_id
            AND
                stop_einschraenkung.stop_id = stoptime_einschraenkung.stop_id
            AND
                stoptime_einschraenkung.trip_id = trip_einschraenkung.trip_id
         )
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof Dulliken:
-- (650 Olten-Zürich R, S und 450 Bern - Olten haben die gleichen route_ids!
    SELECT
    stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count) AS gtfs_count,
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Dulliken'
    AND
        substring(linienname from 1 for 4) = 'L650'
    GROUP BY
        stop_name,
        linienname,
        gtfs_count,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof Däniken
-- (650 Olten-Zürich R, S und 450 Bern - Olten haben die gleichen route_ids!
    SELECT
    stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count) AS gtfs_count,
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Däniken'
    AND
        substring(linienname from 1 for 4) = 'L650'        
    GROUP BY
        stop_name,
        linienname,
        gtfs_count,
        unternehmer,
        verkehrsmittel

     UNION ALL

-- Bahnhof Schönenwerd
-- (650 Olten-Zürich R, S und 450 Bern - Olten haben die gleichen route_ids!
    SELECT
    stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count) AS gtfs_count,
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Schönenwerd SO'
    AND
        substring(linienname from 1 for 4) = 'L650'
    AND
        linienname LIKE 'L650%'
    GROUP BY
        stop_name,
        linienname,
        gtfs_count,
        unternehmer,
        verkehrsmittel
        
    UNION ALL

-- Bahnhof Grenchen Süd
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Grenchen Süd'
    AND
        substring(linienname from 1 for 4) = 'L410'
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

   UNION ALL

-- Bahnhof Murgenthal
-- (650 Olten-Zürich R, S und 450 Bern - Olten haben die gleichen route_ids!
    SELECT
    stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count) AS gtfs_count,
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Murgenthal'
    AND
        substring(linienname from 1 for 4) = 'L450'
    GROUP BY
        stop_name,
        linienname,
        gtfs_count,
        unternehmer,
        verkehrsmittel

     UNION ALL

-- Bahnhof Dornach-Arlesheim:
-- 230 Biel - Delémont und 500 Basel-Olten S
-- haben die gleiche route_id = 4-3-j19-1 
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Dornach-Arlesheim'
    AND
        linienname = 'L230 Basel - Delémont (S3)'
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof Grenchen Nord
    SELECT
        stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> stop_name
    AND
        stop_name = 'Grenchen Nord'
    AND
        route_desc = 'RegioExpress'              -- InterCity werden nicht gezaehlt
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Flüh, Bahnhof (beide Tram und Bus), in GTFS Name für
-- beide gleich, Abt. OeV wünscht Unterscheidung
    SELECT
        'Flüh Bahnhof' AS stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> 'Flüh, Bahnhof'
    AND
        stop_name = 'Flüh, Bahnhof'
    AND
        route_desc = 'Tram'
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel

    UNION ALL

-- Bahnhof: Flüh, Bahnhof
    SELECT
        'Flüh, Bahnhof' AS stop_name,
        linienname,
        unternehmer,
        sum(gtfs_count),
        verkehrsmittel
    FROM
        abfahrten
    WHERE
        trip_headsign <> 'Flüh, Bahnhof'
    AND
        stop_name = 'Flüh, Bahnhof'
    AND
         route_desc = 'Bus'
    GROUP BY
        stop_name,
        linienname,
        unternehmer,
        verkehrsmittel
-- **************** Ende Block für abfahrten_oev_guete.sql ********************
)
;


-- Alle  Haltestellen, die wegen pickup_type = 0 herausfallen
-- oder am Stichtag 0 Abfahrten haben
INSERT INTO
     avt_oevkov_${currentYear}.auswertung_auswertung_gtfs
     (
          haltestellenname,
          linie, unternehmer,
          anzahl_abfahrten_linie,
          verkehrsmittel
     )
     (
        WITH calendar AS (
        SELECT
            service_id,
        CASE
        WHEN (SELECT BTRIM(lower(to_char((
                         SELECT
                                 stichtag
                             FROM
                                    avt_oevkov_${currentYear}.sachdaten_oevkov_daten), 'Day')))) = 'thursday'
             THEN thursday
        WHEN (SELECT BTRIM(lower(to_char((
                         SELECT
                                 stichtag
                             FROM
                                    avt_oevkov_${currentYear}.sachdaten_oevkov_daten), 'Day')))) = 'tuesday'
             THEN tuesday
        END AS dayofweek
        FROM
            avt_oevkov_${currentYear}.gtfs_calendar
    ),
    exception AS (
        SELECT
            service_id,
            exception_type
        FROM
            avt_oevkov_${currentYear}.gtfs_calendar_dates
        WHERE
            datum = (
                            SELECT
                                stichtag
                            FROM
                                avt_oevkov_${currentYear}.sachdaten_oevkov_daten)
    )
     SELECT
         stop_name,
         linie.linienname,
         agency.unternehmer,
         0 as gtfs_count,
         CASE
                WHEN route_desc = 'Bus'
                     THEN 1
                WHEN route_desc IN ('RegioExpress', 'InterRegio', 'Intercity')
                     THEN 2
                WHEN route_desc IN ('Regionalzug', 'S-Bahn', 'Tram')
                    THEN 3
            END AS verkehrsmittel
     FROM
        avt_oevkov_${currentYear}.gtfs_agency AS agency,
        avt_oevkov_${currentYear}.gtfs_route AS route,
        avt_oevkov_${currentYear}.gtfs_trip AS trip,
        avt_oevkov_${currentYear}.gtfs_stoptime AS stoptime,
        avt_oevkov_${currentYear}.gtfs_stop AS stop,
        avt_oevkov_${currentYear}.sachdaten_linie_route AS linie
     WHERE
         (
         trip.service_id IN (
             SELECT
                 service_id
             FROM
                 calendar
             WHERE
                 dayofweek = 1
        )
        OR
        trip.service_id IN (
            SELECT
                service_id
            FROM
                exception
            WHERE
                exception_type = 1
         )
    )
    AND
        trip.service_id NOT IN (
            SELECT
                service_id
            FROM
                exception
            WHERE
                exception_type = 2
    )
    AND
    stop.stop_name||linienname NOT IN (
        SELECT
            haltestellenname||linie
        FROM 
            avt_oevkov_${currentYear}.auswertung_auswertung_gtfs
    )
    AND
        agency.agency_id::text = route.agency_id  
    AND
        route.route_id = trip.route_id
    AND
        route.route_id = linie.route_id
    AND
        stop.stop_id = stoptime.stop_id
    AND
        stoptime.trip_id = trip.trip_id
    AND
        pickup_type > 0
    AND
        route_desc = 'Bus'
     GROUP BY
    stop.stop_name,
    linie.linienname,
    agency.unternehmer,
    verkehrsmittel
)
;

-- Gewichtung schreiben
UPDATE
    avt_oevkov_${currentYear}.auswertung_auswertung_gtfs AS auswertung
SET
    gewichtung = verkehrsmittel.gewichtung
FROM
    avt_oevkov_${currentYear}.sachdaten_verkehrsmittel AS verkehrsmittel
WHERE
    auswertung.verkehrsmittel = verkehrsmittel.verkehrsmittel
;