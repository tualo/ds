DELIMITER ;
CREATE OR REPLACE VIEW `ds_renderer_stylesheet_attributes_dd` AS
select `ds_renderer_stylesheet_attributes`.`attribute` AS `attribute`
from `ds_renderer_stylesheet_attributes`
group by `ds_renderer_stylesheet_attributes`.`attribute`;