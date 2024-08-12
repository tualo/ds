DELIMITER;
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO `ds` (`allowform`,`alternativeformxtype`,`character_set_name`,`class_name`,`combined`,`cssstyle`,`default_pagesize`,`displayfield`,`existsreal`,`globalsearch`,`hint`,`listselectionmodel`,`listviewbaseclass`,`listxtypeprefix`,`modelbaseclass`,`overview_tpl`,`phpexporter`,`phpexporterfilename`,`read_filter`,`read_table`,`reorderfield`,`searchany`,`searchfield`,`showactionbtn`,`sortfield`,`special_add_panel`,`syncable`,`sync_table`,`sync_view`,`table_name`,`title`,`use_history`,`writetable`) VALUES ('0','','','Datenstamm','0','','100','referenced_table_name','1','0','','tualomultirowmodel','Tualo.DataSets.ListView','listview','Tualo.DataSets.model.Basic','','XlsxWriter','{GUID}','','view_readtable_ds_referenced_manual','','1','referenced_table_name','1','referenced_table_name','','0','','','ds_referenced_manual','DS manuelle Referenzen','0','') ON DUPLICATE KEY UPDATE `allowform`=values(`allowform`),`alternativeformxtype`=values(`alternativeformxtype`),`character_set_name`=values(`character_set_name`),`class_name`=values(`class_name`),`combined`=values(`combined`),`cssstyle`=values(`cssstyle`),`default_pagesize`=values(`default_pagesize`),`displayfield`=values(`displayfield`),`existsreal`=values(`existsreal`),`globalsearch`=values(`globalsearch`),`hint`=values(`hint`),`listselectionmodel`=values(`listselectionmodel`),`listviewbaseclass`=values(`listviewbaseclass`),`listxtypeprefix`=values(`listxtypeprefix`),`modelbaseclass`=values(`modelbaseclass`),`overview_tpl`=values(`overview_tpl`),`phpexporter`=values(`phpexporter`),`phpexporterfilename`=values(`phpexporterfilename`),`read_filter`=values(`read_filter`),`read_table`=values(`read_table`),`reorderfield`=values(`reorderfield`),`searchany`=values(`searchany`),`searchfield`=values(`searchfield`),`showactionbtn`=values(`showactionbtn`),`sortfield`=values(`sortfield`),`special_add_panel`=values(`special_add_panel`),`syncable`=values(`syncable`),`sync_table`=values(`sync_table`),`sync_view`=values(`sync_view`),`table_name`=values(`table_name`),`title`=values(`title`),`use_history`=values(`use_history`),`writetable`=values(`writetable`); 
INSERT IGNORE INTO `ds_column` (`character_maximum_length`,`character_set_name`,`column_key`,`column_name`,`column_type`,`data_type`,`existsreal`,`fieldtype`,`is_nullable`,`is_primary`,`privileges`,`table_name`,`writeable`) VALUES ('128','utf8mb4','PRI','referenced_table_name','varchar(128)','varchar','1','','NO','1','select,insert,update,references','ds_referenced_manual','1') ; 
INSERT IGNORE INTO `ds_column` (`character_maximum_length`,`character_set_name`,`column_key`,`column_name`,`column_type`,`data_type`,`existsreal`,`fieldtype`,`is_nullable`,`is_primary`,`privileges`,`table_name`,`writeable`) VALUES ('128','utf8mb4','PRI','table_name','varchar(128)','varchar','1','','NO','1','select,insert,update,references','ds_referenced_manual','1') ; 
INSERT IGNORE INTO `ds_column_list_label` (`active`,`column_name`,`editor`,`filterstore`,`flex`,`grouped`,`hidden`,`label`,`language`,`listfiltertype`,`position`,`renderer`,`summaryrenderer`,`summarytype`,`table_name`,`xtype`) VALUES ('1','referenced_table_name','combobox_ds_tabelle','','1.00','0','0','Verweis','DE','','0','','','','ds_referenced_manual','column_ds_tabelle') ; 
INSERT IGNORE INTO `ds_column_list_label` (`active`,`column_name`,`editor`,`filterstore`,`flex`,`grouped`,`hidden`,`label`,`language`,`listfiltertype`,`position`,`renderer`,`summaryrenderer`,`summarytype`,`table_name`,`xtype`) VALUES ('1','table_name','combobox_ds_tabelle','','1.00','0','0','Tabelle','DE','','0','','','','ds_referenced_manual','column_ds_tabelle') ; 
INSERT IGNORE INTO `ds_column_form_label` (`active`,`allowempty`,`column_name`,`field_path`,`flex`,`hidden`,`label`,`language`,`position`,`table_name`,`xtype`) VALUES ('1','1','referenced_table_name','Allgemein','1.00','0','Verweis','DE','0','ds_referenced_manual','combobox_ds_tabelle') ; 
INSERT IGNORE INTO `ds_column_form_label` (`active`,`allowempty`,`column_name`,`field_path`,`flex`,`hidden`,`label`,`language`,`position`,`table_name`,`xtype`) VALUES ('1','1','table_name','Allgemein','1.00','0','Tabelle','DE','0','ds_referenced_manual','combobox_ds_tabelle') ; 
INSERT IGNORE INTO `ds_reference_tables` (`active`,`autosync`,`columnsdef`,`constraint_name`,`existsreal`,`path`,`position`,`reference_table_name`,`searchable`,`table_name`,`tabtitle`) VALUES ('0','1','{\"referenced_table_name\":\"table_name\"}','fk_ds_referenced_manual_referenced_table_name','1','','99999','ds','0','ds_referenced_manual','') ; 
INSERT IGNORE INTO `ds_reference_tables` (`active`,`autosync`,`columnsdef`,`constraint_name`,`existsreal`,`path`,`position`,`reference_table_name`,`searchable`,`table_name`,`tabtitle`) VALUES ('0','1','{\"table_name\":\"table_name\"}','fk_ds_referenced_manual_table_name','1','','99999','ds','0','ds_referenced_manual','') ; 
INSERT IGNORE INTO `ds_access` (`append`,`delete`,`read`,`role`,`table_name`,`write`) VALUES ('0','0','1','_default_','ds_referenced_manual','0') ; 
INSERT IGNORE INTO `ds_access` (`append`,`delete`,`read`,`role`,`table_name`,`write`) VALUES ('1','1','0','administration','ds_referenced_manual','1') ; 
SET FOREIGN_KEY_CHECKS=1;