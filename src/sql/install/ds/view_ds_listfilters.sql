delimiter ;

CREATE OR REPLACE VIEW  `view_ds_access_by_role` AS select `ds_access`.`table_name` AS `table_name` from `ds_access` where `ds_access`.`role` in (select `view_session_groups`.`group` from `view_session_groups`) and `ds_access`.`read` + `ds_access`.`write` + `ds_access`.`delete` + `ds_access`.`append` > 0 group by `ds_access`.`table_name` ;

create or replace view view_ds_listfilters as
select

lower(concat(ds_dropdownfields.table_name,'_',ds_dropdownfields.name,'_listfilter')) `id`,
(concat(ds.title,' ',ds_dropdownfields.name,'')) `name`
from 

ds_dropdownfields
join ds
    on ds_dropdownfields.table_name = ds.table_name
    and ds.existsreal=1
join view_ds_access_by_role ds_access
on ds.table_name = ds_access.table_name
union 
select '' `id`, 'Standard' `name`

union 
select 'tualonumber' `id`, 'Zahlenfilter (erweitert)' `name`

union 
select 'date' `id`, 'Datumsfilter' `name`

union 
select 'string' `id`, 'Textfilter' `name`

union 
select 'number' `id`, 'Zahlenfilter' `name`

union 
select 'boolean' `id`, 'Wahrheitswerte' `name`

;


-- BEGIN DS view_ds_listfilters
-- NAME: Listenfilter

insert into `ds`
                    (`table_name`)
                    values
                    ('view_ds_listfilters')
                    on duplicate key update `table_name`=values(`table_name`);
update `ds` set `title`='Listenfilter',`reorderfield`='',`use_history`='0',`searchfield`='id',`displayfield`='id',`sortfield`='id',`searchany`='1',`hint`='',`overview_tpl`='',`sync_table`='',`writetable`='',`globalsearch`='0',`listselectionmodel`='cellmodel',`sync_view`='',`syncable`='0',`cssstyle`='',`alternativeformxtype`='',`read_table`='',`class_name`='Unklassifiziert',`special_add_panel`='',`existsreal`='1',`character_set_name`='',`read_filter`='',`listxtypeprefix`='listview',`phpexporter`='XlsxWriter',`phpexporterfilename`='',`combined`='0',`default_pagesize`='100',`allowForm`='0',`listviewbaseclass`='Tualo.DataSets.ListView',`showactionbtn`='1' where `table_name`='view_ds_listfilters';
insert into `ds_column`
                    (`table_name`,`column_name`)
                    values
                    ('view_ds_listfilters','id')
                    on duplicate key update `table_name`=values(`table_name`),`column_name`=values(`column_name`);
update `ds_column` set `default_value`='',`default_max_value`='10000000',`default_min_value`='0',`update_value`='',`is_primary`='0',`syncable`='0',`referenced_table`='',`referenced_column_name`='',`is_nullable`='YES',`is_referenced`='',`writeable`='1',`note`='',`data_type`='varchar',`column_key`='',`column_type`='varchar(240)',`character_maximum_length`='240',`numeric_precision`='0',`numeric_scale`='0',`character_set_name`='utf8',`privileges`='select,insert,update,references',`existsreal`='1',`deferedload`='0' where `table_name`='view_ds_listfilters' and `column_name`='id';
insert into `ds_column`
                    (`table_name`,`column_name`)
                    values
                    ('view_ds_listfilters','name')
                    on duplicate key update `table_name`=values(`table_name`),`column_name`=values(`column_name`);
update `ds_column` set `default_value`='',`default_max_value`='10000000',`default_min_value`='0',`update_value`='',`is_primary`='0',`syncable`='0',`referenced_table`='',`referenced_column_name`='',`is_nullable`='YES',`is_referenced`='',`writeable`='1',`note`='',`data_type`='varchar',`column_key`='',`column_type`='varchar(356)',`character_maximum_length`='356',`numeric_precision`='0',`numeric_scale`='0',`character_set_name`='utf8',`privileges`='select,insert,update,references',`existsreal`='1',`deferedload`='0' where `table_name`='view_ds_listfilters' and `column_name`='name';
insert into `ds_access`
                    (`role`,`table_name`)
                    values
                    ('_default_','view_ds_listfilters')
                    on duplicate key update `role`=values(`role`),`table_name`=values(`table_name`);
update `ds_access` set `read`='1',`write`='0',`delete`='0',`append`='0',`existsreal`='0' where `role`='_default_' and `table_name`='view_ds_listfilters';
insert into `ds_column_list_label`
                    (`table_name`,`column_name`,`language`,`label`)
                    values
                    ('view_ds_listfilters','id','DE','id')
                    on duplicate key update `table_name`=values(`table_name`),`column_name`=values(`column_name`),`language`=values(`language`),`label`=values(`label`);
update `ds_column_list_label` set `xtype`='gridcolumn',`editor`='',`position`='999',`summaryrenderer`='',`renderer`='',`summarytype`='',`hidden`='0',`active`='1',`filterstore`='',`grouped`='0',`flex`='1.00',`direction`='',`align`='',`listfiltertype`='' where `table_name`='view_ds_listfilters' and `column_name`='id' and `language`='DE';
insert into `ds_column_list_label`
                    (`table_name`,`column_name`,`language`,`label`)
                    values
                    ('view_ds_listfilters','name','DE','name')
                    on duplicate key update `table_name`=values(`table_name`),`column_name`=values(`column_name`),`language`=values(`language`),`label`=values(`label`);
update `ds_column_list_label` set `xtype`='gridcolumn',`editor`='',`position`='999',`summaryrenderer`='',`renderer`='',`summarytype`='',`hidden`='0',`active`='1',`filterstore`='',`grouped`='0',`flex`='1.00',`direction`='',`align`='',`listfiltertype`='' where `table_name`='view_ds_listfilters' and `column_name`='name' and `language`='DE';
insert into `ds_dropdownfields`
                    (`table_name`,`name`)
                    values
                    ('view_ds_listfilters','id')
                    on duplicate key update `table_name`=values(`table_name`),`name`=values(`name`);
update `ds_dropdownfields` set `idfield`='id',`displayfield`='name',`filterconfig`='' where `table_name`='view_ds_listfilters' and `name`='id';
-- END DS view_ds_listfilters

