# ds

Datenstämme, Verwalten von Tabellen und Zugriffsrechten

## DSX-Abhaengigkeit

Die PHP-Lese- und Schreibwege benoetigen `tualo/dsx` ab Version 1.0.5. Bei Anwendungen
mit `composer.lock` muss die Abhaengigkeit im Lockfile aktualisiert und
anschliessend installiert werden; `composer dump-autoload` allein aktualisiert
das Paket nicht. Falls der gemeinsame Logger wegen einer veralteten
DSX-Installation fehlt, wird der urspruengliche Fehler mit einem Hinweis auf
die erforderliche Paketversion protokolliert.

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

Wenn die Verbindung verfuegbar ist, wird der Galera-Hostname mit
`SELECT @@hostname` ermittelt; ein Fehler dabei wird im Logkontext festgehalten.
Waehrend eines ungepufferten Reads wird diese Abfrage nicht ausgefuehrt.
Das konfigurierte Schema ist kein Nachweis fuer das aktuell ausgewaehlte Schema;
das Verbindungsziel ist bei HAProxy kein Nachweis fuer den tatsaechlichen
Backend-Knoten.
Dateiausgabe und Log-Level richten sich nach der zentralen Logger-Konfiguration.

Die DS-Routen geben bei Fehlern explizit `success: false` und `msg` zurueck,
auch wenn ein nachgelagerter Read nach einem Schreibvorgang fehlschlaegt.
Ein solcher Fehler bedeutet nicht, dass der Schreibvorgang zurueckgerollt wurde.
Direkt in den Routen abgefangene Exceptions werden ebenfalls im Kanal `dstable`
protokolliert. Der Einzelabruf prueft den DSTable-Fehlerstatus und fuehrt nur
einen Read aus; SQL-Statements werden dort nicht als Fehlerantwort ausgegeben.

Die Fehlerprotokollierung laesst sich ohne Datenbank mit
`php tests/ReadErrorLoggingTest.php` und
`php tests/MissingDsxErrorLoggingTest.php` pruefen.

## MariaDB und group_concat_max_len

Die Prozedur `dsx_rest_api_get` setzt `group_concat_max_len` auf `173741824`.
Dieser Wert gilt fuer die anschliessende Datenabfrage von `DSTable` und
`DSReadRoute` und bleibt wie bisher auf der Verbindung bestehen. PHP stellt
keinen vorherigen Wert wieder her. Der Export setzt vor dem Prozeduraufruf
keinen zusaetzlichen Maximalwert.

In der untersuchten MariaDB-11.8.9-Umgebung trat das Problem mit leeren
`JSON_ARRAYAGG`-View-Ergebnissen beim Erreichen bzw. Ueberschreiten des
Maximalwerts auf. Der bisherige Wert `4294967295` liegt ueber dem dort
zulaessigen Maximum von `1073741824`. Die geaenderte SQL-Prozedur muss auch in
der Datenbank installiert werden; ein Austausch der PHP-Dateien allein aendert
sie nicht.

Auch ein kleinerer Wert muss ausreichend Platz fuer die benoetigten Aggregate
bieten: MariaDB-Warnung 1260 wegen eines abgeschnittenen `GROUP_CONCAT`- oder
`JSON_ARRAYAGG`-Ergebnisses wird beim Legacy-Read als Fehler gemeldet und ueber
`DSTable` bzw. die Routen protokolliert.

Der Regressionstest fuer den PHP-Leseweg ist
`php tests/DSReadRouteGroupConcatTest.php`. Fuer den
Integrationstest `tests/DSReadRouteGroupConcatIntegrationTest.php` muessen
`DS_TEST_MYSQL_HOST` und `DS_TEST_MYSQL_PORT` auf einen isolierten Testserver
zeigen; optional koennen `DS_TEST_MYSQL_USER`, `DS_TEST_MYSQL_PASSWORD` und
`DS_TEST_BSC_SRC` sowie `DS_TEST_DSX_SRC` angegeben werden. Der Test erstellt
und entfernt ein eigenes Testschema und benoetigt dafuer entsprechende
Datenbankrechte. Ohne Pfadangaben werden die benachbarten Pakete `../bsc/src`
und `../dsx/src` verwendet.