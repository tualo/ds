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


select

lower(concat(ds_dropdownfields.table_name,'_',ds_dropdownfields.name,'_tagfield_filter')) `id`,
(concat('Tagfilter ',ds.title,' ',ds_dropdownfields.name,'')) `name`
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

SET FOREIGN_KEY_CHECKS=0;
INSERT INTO `ds` (`allowform`,`alternativeformxtype`,`autosave`,`base_store_class`,`character_set_name`,`class_name`,`combined`,`cssstyle`,`default_pagesize`,`displayfield`,`existsreal`,`globalsearch`,`hint`,`listselectionmodel`,`listviewbaseclass`,`listxtypeprefix`,`modelbaseclass`,`overview_tpl`,`phpexporter`,`phpexporterfilename`,`read_filter`,`read_table`,`reorderfield`,`searchany`,`searchfield`,`showactionbtn`,`sortfield`,`special_add_panel`,`syncable`,`sync_table`,`sync_view`,`table_name`,`title`,`use_history`,`use_insert_for_update`,`writetable`) VALUES ('0','','0','Tualo.DataSets.data.Store','','Unklassifiziert','0','','100','id','1','0','','cellmodel','Tualo.DataSets.ListView','listview','Tualo.DataSets.model.Basic','','XlsxWriter','','','','','1','id','1','id','','0','','','view_ds_listfilters','Listenfilter','0','0','') ON DUPLICATE KEY UPDATE `allowform`=values(`allowform`),`alternativeformxtype`=values(`alternativeformxtype`),`autosave`=values(`autosave`),`base_store_class`=values(`base_store_class`),`character_set_name`=values(`character_set_name`),`class_name`=values(`class_name`),`combined`=values(`combined`),`cssstyle`=values(`cssstyle`),`default_pagesize`=values(`default_pagesize`),`displayfield`=values(`displayfield`),`existsreal`=values(`existsreal`),`globalsearch`=values(`globalsearch`),`hint`=values(`hint`),`listselectionmodel`=values(`listselectionmodel`),`listviewbaseclass`=values(`listviewbaseclass`),`listxtypeprefix`=values(`listxtypeprefix`),`modelbaseclass`=values(`modelbaseclass`),`overview_tpl`=values(`overview_tpl`),`phpexporter`=values(`phpexporter`),`phpexporterfilename`=values(`phpexporterfilename`),`read_filter`=values(`read_filter`),`read_table`=values(`read_table`),`reorderfield`=values(`reorderfield`),`searchany`=values(`searchany`),`searchfield`=values(`searchfield`),`showactionbtn`=values(`showactionbtn`),`sortfield`=values(`sortfield`),`special_add_panel`=values(`special_add_panel`),`syncable`=values(`syncable`),`sync_table`=values(`sync_table`),`sync_view`=values(`sync_view`),`table_name`=values(`table_name`),`title`=values(`title`),`use_history`=values(`use_history`),`use_insert_for_update`=values(`use_insert_for_update`),`writetable`=values(`writetable`); 
INSERT IGNORE INTO `ds_column` (`character_maximum_length`,`character_set_name`,`column_key`,`column_name`,`column_type`,`data_type`,`default_max_value`,`default_min_value`,`default_value`,`deferedload`,`existsreal`,`fieldtype`,`hint`,`is_generated`,`is_nullable`,`is_primary`,`is_referenced`,`note`,`numeric_precision`,`numeric_scale`,`privileges`,`referenced_column_name`,`referenced_table`,`syncable`,`table_name`,`update_value`,`writeable`) VALUES ('245','utf8mb3','','id','varchar(245)','varchar','10000000','0','','0','1','','','NEVER','YES','1','','','0','0','select,insert,update,references','','','0','view_ds_listfilters','','1') ; 
INSERT IGNORE INTO `ds_column` (`character_maximum_length`,`character_set_name`,`column_key`,`column_name`,`column_type`,`data_type`,`default_max_value`,`default_min_value`,`default_value`,`deferedload`,`existsreal`,`fieldtype`,`is_generated`,`is_nullable`,`is_primary`,`is_referenced`,`note`,`numeric_precision`,`numeric_scale`,`privileges`,`referenced_column_name`,`referenced_table`,`syncable`,`table_name`,`update_value`,`writeable`) VALUES ('366','utf8mb3','','name','varchar(366)','varchar','10000000','0','','0','1','','NEVER','YES','0','','','0','0','select,insert,update,references','','','0','view_ds_listfilters','','1') ; 
INSERT IGNORE INTO `ds_column_list_label` (`active`,`align`,`column_name`,`editor`,`filterstore`,`flex`,`grouped`,`hidden`,`label`,`language`,`listfiltertype`,`position`,`renderer`,`summaryrenderer`,`summarytype`,`table_name`,`xtype`) VALUES ('1','','id','','','1','0','0','id','DE','','999','','','','view_ds_listfilters','gridcolumn') ; 
INSERT IGNORE INTO `ds_column_list_label` (`active`,`align`,`column_name`,`editor`,`filterstore`,`flex`,`grouped`,`hidden`,`label`,`language`,`listfiltertype`,`position`,`renderer`,`summaryrenderer`,`summarytype`,`table_name`,`xtype`) VALUES ('1','','name','','','1','0','0','name','DE','','999','','','','view_ds_listfilters','gridcolumn') ; 
INSERT IGNORE INTO `ds_column_form_label` (`active`,`allowempty`,`column_name`,`field_path`,`flex`,`hidden`,`label`,`language`,`position`,`table_name`,`xtype`) VALUES ('0','0','id','Allgemein','1','1','id','DE','999','view_ds_listfilters','displayfield') ; 
INSERT IGNORE INTO `ds_column_form_label` (`active`,`allowempty`,`column_name`,`field_path`,`flex`,`hidden`,`label`,`language`,`position`,`table_name`,`xtype`) VALUES ('0','0','name','Allgemein','1','1','name','DE','999','view_ds_listfilters','displayfield') ; 
INSERT IGNORE INTO `ds_dropdownfields` (`displayfield`,`filterconfig`,`idfield`,`name`,`table_name`) VALUES ('name','','id','id','view_ds_listfilters') ; 
INSERT IGNORE INTO `ds_access` (`append`,`delete`,`read`,`role`,`table_name`,`write`) VALUES ('0','0','1','_default_','view_ds_listfilters','0') ; 
INSERT IGNORE INTO `ds_access` (`append`,`delete`,`read`,`role`,`table_name`,`write`) VALUES ('0','0','0','administration','view_ds_listfilters','0') ; 
REPLACE INTO `docsystem_ds` (`table_name`) VALUES ('view_ds_listfilters') ; 
SET FOREIGN_KEY_CHECKS=1;