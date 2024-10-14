delimiter ;

CREATE TABLE IF NOT EXISTS`ds_listplugins_ptypes` (
  `type` varchar(255) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS`ds_listplugins_placements` (
  `placement` varchar(50) PRIMARY KEY
);
INSERT IGNORE INTO `ds_listplugins_placements` (`placement`) VALUES ('view');
INSERT IGNORE INTO `ds_listplugins_placements` (`placement`) VALUES ('viewConfig');


-- summary

CREATE TABLE IF NOT EXISTS `ds_listplugins` (
  `table_name` varchar(128) NOT NULL,
  `ptype` varchar(255) NOT NULL,
  `placement` varchar(50) DEFAULT 'view',
  PRIMARY KEY (`table_name`,`ptype`),
  KEY `fk_ds_listplugins_ds` (`table_name`),
  CONSTRAINT `fk_ds_listplugins_ds` FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) 
    ON DELETE CASCADE ON UPDATE CASCADE
);

alter table `ds_listplugins` 
    ADD 
    CONSTRAINT `fk_ds_listplugins_ptype` 
    FOREIGN KEY IF NOT EXISTS (`ptype`) REFERENCES `ds_listplugins_ptypes` (`type`) 
ON DELETE CASCADE ON UPDATE CASCADE;

alter table `ds_listplugins` 
    ADD 
    CONSTRAINT `fk_ds_listplugins_placement` 
    FOREIGN KEY IF NOT EXISTS (`placement`) REFERENCES `ds_listplugins_placements` (`placement`) 
ON DELETE CASCADE ON UPDATE CASCADE;
