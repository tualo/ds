delimiter ;
CREATE OR REPLACE VIEW  `view_readtable_ds_column_list_label_all` AS
 select ifnull(`ds_column_list_label`.`table_name`,`ic`.`table_name`) AS `table_name`,
 ifnull(`ds_column_list_label`.`column_name`,`ic`.`column_name`) AS `column_name`,
 ifnull(`ds_column_list_label`.`language`,'DE') AS `language`,
 ifnull(`ds_column_list_label`.`label`,`ic`.`column_name`) AS `label`,
 ifnull(`ds_column_list_label`.`xtype`,'gridcolumn') AS `xtype`,
 ifnull(`ds_column_list_label`.`editor`,'') AS `editor`,
 ifnull(`ds_column_list_label`.`position`,999) AS `position`,
 ifnull(`ds_column_list_label`.`summaryrenderer`,'') AS `summaryrenderer`,
 ifnull(`ds_column_list_label`.`summarytype`,'') AS `summarytype`,
 ifnull(`ds_column_list_label`.`filterstore`,'') AS `filterstore`,
 ifnull(`ds_column_list_label`.`hidden`,1) AS `hidden` ,
 ifnull(`ds_column_list_label`.`renderer`,'') AS `renderer`,
 ifnull(`ds_column_list_label`.`active`,0)   AS `active`,
 ifnull(`ds_column_list_label`.`grouped`,0)   AS `grouped`,
 ifnull(`ds_column_list_label`.`flex`,1)   AS `flex`,
 ifnull(`ds_column_list_label`.`listfiltertype`,'') `listfiltertype`,
 
 if(`ds_column_list_label`.`column_name` is null,1,0) AS `__virtual`

 from (`ds_column` `ic` left join `ds_column_list_label`
   on(((`ds_column_list_label`.`table_name` = `ic`.`table_name`)
   and (`ds_column_list_label`.`column_name` = `ic`.`column_name`))));

call fill_ds_column('view_readtable_ds_column_list_label_all');