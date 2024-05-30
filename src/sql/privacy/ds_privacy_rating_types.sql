delimiter ;


CREATE TABLE IF NOT EXISTS `ds_privacy_rating_types` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `score` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
);


insert ignore into ds_privacy_rating_types (id,name,score) values ('0450990c-90f3-11ed-9169-002590c4e7c6','Konfigurationsdaten',10);
insert ignore into ds_privacy_rating_types (id,name,score) values ('14e46da2-90f2-11ed-9169-002590c4e7c6','Anschriften ohne Personenbezug',75);
insert ignore into ds_privacy_rating_types (id,name,score) values ('afe0cec2-90f2-11ed-9169-002590c4e7c6','Anmeldeinformationen',100);
insert ignore into ds_privacy_rating_types (id,name,score) values ('14d1f091-90f2-11ed-9169-002590c4e7c6','Personendaten',100);
insert ignore into ds_privacy_rating_types (id,name,score) values ('cf8cf6f0-90f2-11ed-9169-002590c4e7c6','Verkehrsdaten',25);
insert ignore into ds_privacy_rating_types (id,name,score) values ('0432bc6b-90f2-11ed-9169-002590c4e7c6','Unternehmenszahlen',50);
insert ignore into ds_privacy_rating_types (id,name,score) values ('undefined','Unbestimmt',0);

