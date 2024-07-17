DELIMITER;
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO `ds` (`allowform`,`alternativeformxtype`,`character_set_name`,`class_name`,`combined`,`cssstyle`,`default_pagesize`,`displayfield`,`existsreal`,`globalsearch`,`hint`,`listselectionmodel`,`listviewbaseclass`,`listxtypeprefix`,`modelbaseclass`,`overview_tpl`,`phpexporter`,`phpexporterfilename`,`read_filter`,`read_table`,`reorderfield`,`searchany`,`searchfield`,`showactionbtn`,`sortfield`,`special_add_panel`,`syncable`,`sync_table`,`sync_view`,`table_name`,`title`,`use_history`,`writetable`) VALUES ('1','','','Datenstamm','0','','1000','name','1','0','','tualomultirowmodel','Tualo.DataSets.ListView','','Tualo.DataSets.model.Basic','','XlsxWriter','ds_privacy_rating_types_{DATE}','','','','0','name','1','score','','0','','','ds_privacy_rating_types','Datenschutz-Bewertungstypen','0','') ON DUPLICATE KEY UPDATE `allowform`=values(`allowform`),`alternativeformxtype`=values(`alternativeformxtype`),`character_set_name`=values(`character_set_name`),`class_name`=values(`class_name`),`combined`=values(`combined`),`cssstyle`=values(`cssstyle`),`default_pagesize`=values(`default_pagesize`),`displayfield`=values(`displayfield`),`existsreal`=values(`existsreal`),`globalsearch`=values(`globalsearch`),`hint`=values(`hint`),`listselectionmodel`=values(`listselectionmodel`),`listviewbaseclass`=values(`listviewbaseclass`),`listxtypeprefix`=values(`listxtypeprefix`),`modelbaseclass`=values(`modelbaseclass`),`overview_tpl`=values(`overview_tpl`),`phpexporter`=values(`phpexporter`),`phpexporterfilename`=values(`phpexporterfilename`),`read_filter`=values(`read_filter`),`read_table`=values(`read_table`),`reorderfield`=values(`reorderfield`),`searchany`=values(`searchany`),`searchfield`=values(`searchfield`),`showactionbtn`=values(`showactionbtn`),`sortfield`=values(`sortfield`),`special_add_panel`=values(`special_add_panel`),`syncable`=values(`syncable`),`sync_table`=values(`sync_table`),`sync_view`=values(`sync_view`),`table_name`=values(`table_name`),`title`=values(`title`),`use_history`=values(`use_history`),`writetable`=values(`writetable`); 
INSERT IGNORE INTO `ds_column` (`character_maximum_length`,`character_set_name`,`column_key`,`column_name`,`column_type`,`data_type`,`default_max_value`,`default_min_value`,`default_value`,`deferedload`,`existsreal`,`fieldtype`,`hint`,`is_nullable`,`is_primary`,`is_referenced`,`note`,`numeric_precision`,`numeric_scale`,`privileges`,`referenced_column_name`,`referenced_table`,`table_name`,`update_value`,`writeable`) VALUES ('36','utf8mb4','PRI','id','varchar(36)','varchar','0','0','{:uuid()}','0','1','','NULL','NO','1','0','','0','0','select,insert,update,references','','','ds_privacy_rating_types','','1') ; 
INSERT IGNORE INTO `ds_column` (`character_maximum_length`,`character_set_name`,`column_key`,`column_name`,`column_type`,`data_type`,`default_max_value`,`default_min_value`,`default_value`,`deferedload`,`existsreal`,`fieldtype`,`hint`,`is_nullable`,`is_primary`,`is_referenced`,`note`,`numeric_precision`,`numeric_scale`,`privileges`,`referenced_column_name`,`referenced_table`,`table_name`,`update_value`,`writeable`) VALUES ('255','utf8mb4','','name','varchar(255)','varchar','0','0','','0','1','','','NO','0','','','0','0','select,insert,update,references','','','ds_privacy_rating_types','','1') ; 
INSERT IGNORE INTO `ds_column` (`character_maximum_length`,`character_set_name`,`column_key`,`column_name`,`column_type`,`data_type`,`default_max_value`,`default_min_value`,`default_value`,`deferedload`,`existsreal`,`fieldtype`,`hint`,`is_nullable`,`is_primary`,`is_referenced`,`note`,`numeric_precision`,`numeric_scale`,`privileges`,`referenced_column_name`,`referenced_table`,`table_name`,`update_value`,`writeable`) VALUES ('0','','','score','int(11)','int','0','0','0','0','1','','NULL','YES','0','0','','10','0','select,insert,update,references','','','ds_privacy_rating_types','','1') ; 
INSERT IGNORE INTO `ds_column_list_label` (`active`,`column_name`,`editor`,`filterstore`,`flex`,`grouped`,`hidden`,`label`,`language`,`listfiltertype`,`position`,`renderer`,`summaryrenderer`,`summarytype`,`table_name`,`xtype`) VALUES ('1','id','','','1.00','0','0','ID','DE','','0','','','','ds_privacy_rating_types','gridcolumn') ; 
INSERT IGNORE INTO `ds_column_list_label` (`active`,`column_name`,`editor`,`filterstore`,`flex`,`grouped`,`hidden`,`label`,`language`,`listfiltertype`,`position`,`renderer`,`summaryrenderer`,`summarytype`,`table_name`,`xtype`) VALUES ('1','name','','','1.00','0','0','Name','DE','','1','','','','ds_privacy_rating_types','gridcolumn') ; 
INSERT IGNORE INTO `ds_column_list_label` (`active`,`column_name`,`editor`,`filterstore`,`flex`,`grouped`,`hidden`,`label`,`language`,`listfiltertype`,`position`,`renderer`,`summaryrenderer`,`summarytype`,`table_name`,`xtype`) VALUES ('1','score','','','1.00','0','0','Bewertung','DE','','2','','','','ds_privacy_rating_types','gridcolumn') ; 
INSERT IGNORE INTO `ds_column_form_label` (`active`,`allowempty`,`column_name`,`field_path`,`flex`,`hidden`,`label`,`language`,`position`,`table_name`,`xtype`) VALUES ('1','0','id','Allgemein/Angaben','1.00','0','ID','DE','0','ds_privacy_rating_types','displayfield') ; 
INSERT IGNORE INTO `ds_column_form_label` (`active`,`allowempty`,`column_name`,`field_path`,`flex`,`hidden`,`label`,`language`,`position`,`table_name`,`xtype`) VALUES ('1','0','name','Allgemein/Angaben','1.00','0','Name','DE','1','ds_privacy_rating_types','textfield') ; 
INSERT IGNORE INTO `ds_column_form_label` (`active`,`allowempty`,`column_name`,`field_path`,`flex`,`hidden`,`label`,`language`,`position`,`table_name`,`xtype`) VALUES ('1','0','score','Allgemein/Angaben','1.00','0','Bewertung','DE','2','ds_privacy_rating_types','number0') ; 
INSERT IGNORE INTO `ds_dropdownfields` (`displayfield`,`filterconfig`,`idfield`,`name`,`table_name`) VALUES ('name','','id','id','ds_privacy_rating_types') ; 
INSERT IGNORE INTO `ds_access` (`append`,`delete`,`read`,`role`,`table_name`,`write`) VALUES ('0','0','1','_default_','ds_privacy_rating_types','0') ; 
INSERT IGNORE INTO `ds_access` (`append`,`delete`,`read`,`role`,`table_name`,`write`) VALUES ('1','1','1','administration','ds_privacy_rating_types','1') ; 
SET FOREIGN_KEY_CHECKS=1;