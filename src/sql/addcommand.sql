delimiter ; 
insert ignore into ds_addcommands_xtypes (id,name) values ('compiler_command','Kompiler');
insert ignore into ds_addcommands_xtypes (id,name) values ('ds_batch_command','Batchupdate');
insert ignore into ds_addcommands_xtypes (id,name) values ('ds_refresh_information_schema_command','DDL-Refresh');



update `ds_column` set `is_primary`=1 where 
`table_name`='view_ds_listfilters' and `column_name`='id'
and (select sum(`is_primary`) from `ds_column` where `table_name`='view_ds_listfilters')=0;



INSERT  IGNORE INTO `ds_addcommands` VALUES
-- ('ds','cmp_setup_export_config_command','toolbar',1,'','x-fa fa-plus'),
-- ('ds','cmp_setup_update_history_tables_command','toolbar',1,'','x-fa fa-plus'),
('ds','compiler_command','toolbar',1,'Kompiler',NULL),
('ds','ds_refresh_information_schema_command','toolbar',1,'DDL-Refresh',NULL);
