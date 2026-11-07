# Volltextsuche einrichten

Diese Anleitung beschreibt die Schritte zur Einrichtung der Volltextsuche für eine Tabelle.

## Voraussetzungen

- Eine bestehende Tabelle im Datenstamm
- Zugriff auf die Datenbank mit ausreichenden Rechten

## Einrichtung Schritt für Schritt

### Geführter Dialog

Im Datenstamm kann der Deferred-Command `ds_ftindex_command`
(`Tualo.cmp.cmp_ds.commands.DSFTIndex`) als Zusatzkommando verwendet werden.
Er übernimmt `table_name` des ausgewählten Datensatzes und führt mit
„Aufbauen“ nacheinander diese Aufrufe aus:

```sql
CALL ds_create_fulltext_search('<tablename>');
CALL refresh_searchft_<tablename>();
```

Die POST-Route `/dsft/run` verwendet `table_name` und `stage=build` bzw.
`stage=refresh`. Sie benötigt den Scope `ds.procedures` und eine Master-Session.
Ohne aktive Suchfelder wird der Vorgang abgelehnt. Der Dialog zeigt beide
Arbeitsschritte und bleibt bei Fehlern für einen erneuten Versuch geöffnet.
Der Strukturaufbau ist nicht transaktional: Nach einem Fehler kann die Struktur
bereits teilweise erstellt sein. Die nachstehenden Metadaten-Schritte sind
bei Bedarf weiterhin separat auszuführen.

### 1. Suchfelder im Datenstamm festlegen

Definieren Sie zunächst im Datenstamm, welche Felder für die Volltextsuche indexiert werden sollen.

### 2. Volltextsuche für die Tabelle erstellen

Führen Sie die Funktion `ds_create_fulltext_search()` aus, um die Volltextsuchstruktur zu erstellen:

```sql
CALL ds_create_fulltext_search('<tablename>');
```

**Hinweis:** Dieser Schritt muss einmalig durchgeführt werden oder nach jeder Änderung der Suchfelder wiederholt werden.

### 3. Datenstamm-Metadaten befüllen

Befüllen Sie die Metadaten für die Volltextsuchtabelle:

```sql
CALL fill_ds('ds_ftsearch_<tablename>');
```

Ersetzen Sie `<tablename>` durch den tatsächlichen Tabellennamen.

### 4. Spalten-Metadaten befüllen

Befüllen Sie die Spalten-Metadaten:

```sql
CALL fill_ds_column('ds_ftsearch_<tablename>');
```

Ersetzen Sie auch hier `<tablename>` durch den tatsächlichen Tabellennamen.

### 5. Suchtabelle initial befüllen

Führen Sie abschließend die Prozedur aus, um die Suchtabelle mit den vorhandenen Daten zu befüllen:

```sql
CALL refresh_searchft_<tablename>();
```

Ersetzen Sie `<tablename>` durch den tatsächlichen Tabellennamen.

## Beispiel

Für eine Tabelle mit dem Namen `kunden` würden die Befehle wie folgt aussehen:

```sql
-- Schritt 2
CALL ds_create_fulltext_search('kunden');

-- Schritt 3
CALL fill_ds('ds_ftsearch_kunden');

-- Schritt 4
CALL fill_ds_column('ds_ftsearch_kunden');

-- Schritt 5
CALL refresh_searchft_kunden();
```

## Wartung

Bei Änderungen an den Suchfeldern muss der Prozess ab Schritt 2 wiederholt werden.
