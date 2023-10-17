DELIMITER ;
CREATE TABLE IF NOT EXISTS `kandidaten_properties` (
  `id` int(11) NOT NULL,
  `property_name` varchar(50) NOT NULL,
  `property_type` varchar(10) NOT NULL,
  `date_value` date NOT NULL DEFAULT curdate(),
  `number_value` decimal(15,6) NOT NULL DEFAULT 0.000000,
  `boolean_value` tinyint(4) NOT NULL DEFAULT 0,
  `string_value` longtext NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`property_name`),
  KEY `fk_kandidaten_properties_ds_property_types` (`property_type`),
  CONSTRAINT `fk_kandidaten_properties` FOREIGN KEY (`id`) REFERENCES `kandidaten` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_kandidaten_properties_ds_property_types` FOREIGN KEY (`property_type`) REFERENCES `ds_property_types` (`type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
