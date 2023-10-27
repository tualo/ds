delimiter ; 
insert ignore into ds_addcommands_xtypes (id,name) values ('compiler_command','Kompiler');
insert ignore into ds_addcommands_xtypes (id,name) values ('ds_batch_command','Batchupdate');
insert ignore into ds_addcommands_xtypes (id,name) values ('ds_refresh_information_schema_command','DDL-Refresh');



update `ds_column` set `is_primary`=1 where 
`table_name`='view_ds_listfilters' and `column_name`='id'
and (select sum(`is_primary`) from `ds_column` where `table_name`='view_ds_listfilters')=0;
