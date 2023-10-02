DELIMITER ;
create or replace view `ds_renderer_stylesheet_attributes_dd` as select `ds_renderer_stylesheet_attributes`.`attribute` AS `attribute` from `ds_renderer_stylesheet_attributes` group by `ds_renderer_stylesheet_attributes`.`attribute`;
