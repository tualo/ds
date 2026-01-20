# Volltextsuche einrichten

Diese Anleitung beschreibt die Schritte zur Einrichtung der Volltextsuche für eine Tabelle.

## Voraussetzungen

- Eine bestehende Tabelle im Datenstamm
- Zugriff auf die Datenbank mit ausreichenden Rechten

## Einrichtung Schritt für Schritt

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
CALL ds_ftsearch_<tablename>();
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
CALL ds_ftsearch_kunden();
```

## Wartung

Bei Änderungen an den Suchfeldern muss der Prozess ab Schritt 2 wiederholt werden.
