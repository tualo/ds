# ds

Datenstämme, Verwalten von Tabellen und Zugriffsrechten

## DSTable-Fehlerdiagnose

Abgefangene Fehler in `read`, `insert`, `update` und `delete` werden ueber
`TualoApplication::logger('dstable')->error(...)` protokolliert. Der bestehende
Fehlerstatus und die Rueckgabewerte bleiben unveraendert.

Der Logkontext enthaelt Operation, Tabellenname, konfiguriertes Schema,
Exception-Kette sowie bei verfuegbarer mysqli-Verbindung Fehlernummer, SQLSTATE,
Verbindungs-ID und Verbindungsziel. Der letzte Statement-Praefix zeigt nur den
SQL-Befehl beziehungsweise den CALL-Routinennamen, nicht die SQL-Parameter.
Request-Inhalte, Filterwerte und Datensaetze werden nicht zusaetzlich geloggt;
die originale Fehlermeldung kann allerdings vom Datenbankserver genannte Werte
enthalten.

Es werden keine Diagnose-SQL-Abfragen ausgefuehrt. Das konfigurierte Schema ist
kein Nachweis fuer das aktuell ausgewaehlte Schema; das Verbindungsziel ist bei
HAProxy kein Nachweis fuer den tatsaechlichen Backend-Knoten.
Dateiausgabe und Log-Level richten sich nach der zentralen Logger-Konfiguration.

Die DS-Routen geben bei Fehlern explizit `success: false` und `msg` zurueck,
auch wenn ein nachgelagerter Read nach einem Schreibvorgang fehlschlaegt.
Ein solcher Fehler bedeutet nicht, dass der Schreibvorgang zurueckgerollt wurde.
Direkt in den Routen abgefangene Exceptions werden ebenfalls im Kanal `dstable`
protokolliert. Der Einzelabruf prueft den DSTable-Fehlerstatus und fuehrt nur
einen Read aus; SQL-Statements werden dort nicht als Fehlerantwort ausgegeben.