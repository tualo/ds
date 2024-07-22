DELIMITER;
 CREATE OR REPLACE VIEW  `view_readtable_ds_column_list_export` AS
 select 
    ifnull(`ds_column_list_export`.`table_name`,`ic`.`table_name`) AS `table_name`,
    ifnull(`ds_column_list_export`.`column_name`,`ic`.`column_name`) AS `column_name`,
    ifnull(`ds_column_list_export`.`language`,'DE') AS `language`,
    ifnull(`ds_column_list_export`.`label`,`ic`.`column_name`) AS `label`,

    ifnull(`ds_column_list_export`.`position`,999) AS `position`,
    ifnull(`ds_column_list_export`.`active`,0) AS `active`
from 
(
  `ds_column` `ic` 
  left join `ds_column_list_export`
  on(((`ds_column_list_export`.`table_name` = `ic`.`table_name`)
  and (`ds_column_list_export`.`column_name` = `ic`.`column_name`)))
);