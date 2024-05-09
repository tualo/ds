delimiter ;


CREATE OR REPLACE VIEW `view_readtable_ds_column_form_label` AS 
select 

    ifnull(`ds_column_form_label`.`table_name`,`ic`.`table_name`) AS `table_name`,
    ifnull(`ds_column_form_label`.`column_name`,`ic`.`column_name`) AS `column_name`,
    ifnull(`ds_column_form_label`.`language`,'DE') AS `language`,
    ifnull(`ds_column_form_label`.`label`,`ic`.`column_name`) AS `label`,
    ifnull(`ds_column_form_label`.`xtype`,'displayfield') AS `xtype`,
    ifnull(`ds_column_form_label`.`field_path`,'Allgemein') AS `field_path`,
    ifnull(`ds_column_form_label`.`position`,999) AS `position`,
    ifnull(`ds_column_form_label`.`hidden`,1) AS `hidden`,
    ifnull(`ds_column_form_label`.`active`,0) AS `active`,
    ifnull(`ds_column_form_label`.`flex`,1) AS `flex`,
    ifnull(`ds_column_form_label`.`allowempty`,0) AS `allowempty`,
    if(`ds_column_form_label`.`column_name` is null,1,0) AS `__virtual`
from (
    `ds_column` `ic` 
    left join `ds_column_form_label` 
    on (`ds_column_form_label`.`table_name` = `ic`.`table_name` and `ds_column_form_label`.`column_name` = `ic`.`column_name`)
);
call fill_ds_column('view_readtable_ds_column_form_label');