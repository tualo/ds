
create table if not exists `briefanreden` (
  id varchar(36) primary key,
  name varchar(255) not null,
  language varchar(4) default 'DE',
  CONSTRAINT `fk_briefanreden_language` FOREIGN KEY (`language`) REFERENCES `languagecodes` (`code`) ON DELETE CASCADE ON UPDATE CASCADE
);
insert ignore into briefanreden (id,name,language) values ('default','Sehr geehrte Damen und Herren','DE');

create table if not exists `geschlecht` (
  id integer primary key,
  name varchar(255) not null
);

insert ignore into geschlecht (id,name) values (0,'nicht bekannt');
insert ignore into geschlecht (id,name) values (1,'männlich');
insert ignore into geschlecht (id,name) values (2,'weiblich');
insert ignore into geschlecht (id,name) values (3,'divers');

CREATE TABLE if not exists `ansprechpartner` (
  `id` varchar(36) NOT NULL,
  `kundennummer` varchar(10) NOT NULL,
  `kostenstelle` int(11) DEFAULT NULL,

  `anrede` varchar(10) DEFAULT '',
  `vorname` varchar(100) DEFAULT '',
  `nachname` varchar(100) DEFAULT '',
  `titel` varchar(100) DEFAULT '',
  `stellung` varchar(100) DEFAULT '',
  `telefon` varchar(100) DEFAULT '',
  `telefax` varchar(100) DEFAULT '',
  `mail` varchar(100) DEFAULT '',
  `serienbrief` tinyint(4) DEFAULT 0,
  `belege` tinyint default 1,
  `mobil` varchar(100) DEFAULT '',
  `briefanrede` varchar(36) DEFAULT '',
  `abteilung` varchar(80) DEFAULT '',
  `gruppe` varchar(30) DEFAULT '',
  `geschlecht` integer DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_ansprechpartner_adressen` (`kundennummer`,`kostenstelle`),
  CONSTRAINT `fk_ansprechpartner_adressen` FOREIGN KEY (`kundennummer`, `kostenstelle`) REFERENCES `adressen` (`kundennummer`, `kostenstelle`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ansprechpartner_briefanreden` FOREIGN KEY (`briefanrede`) REFERENCES `briefanreden` (`id`) ON DELETE restrict ON UPDATE CASCADE,
  CONSTRAINT `fk_ansprechpartner_geschlecht` FOREIGN KEY (`geschlecht`) REFERENCES `geschlecht` (`id`) ON DELETE restrict ON UPDATE CASCADE
);

create or replace view `view_ansprechpartner_titel_dd` as
select distinct titel from ansprechpartner;

create or replace view `view_ansprechpartner_abteilung_dd` as
select distinct abteilung from ansprechpartner;

create or replace view `view_ansprechpartner_nachname_dd` as
select distinct nachname from ansprechpartner;

create or replace view `view_ansprechpartner_vorname_dd` as
select distinct vorname from ansprechpartner;
