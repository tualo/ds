DELIMITER ;

CREATE TABLE `ds_renderer_stylesheet` (
  `classname` varchar(50) NOT NULL,
  `group` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`classname`),
  KEY `idx_ds_renderer_stylesheet_group` (`group`),
  CONSTRAINT `fk_ds_renderer_stylesheet_group` FOREIGN KEY (`group`) REFERENCES `ds_renderer_stylesheet_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ;