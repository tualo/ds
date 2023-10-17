DELIMITER ;
CREATE TABLE IF NOT EXISTS `ds_property_definition` (
  `table_name` varchar(128) NOT NULL,
  `property` varchar(50) NOT NULL,
  `type` varchar(10) NOT NULL,
  PRIMARY KEY (`table_name`,`property`),
  KEY `fk_ds_property_definition_ds_property_types` (`type`),
  CONSTRAINT `fk_ds_property_definition_ds` FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ds_property_definition_ds_property_types` FOREIGN KEY (`type`) REFERENCES `ds_property_types` (`type`) ON DELETE CASCADE ON UPDATE CASCADE
);
