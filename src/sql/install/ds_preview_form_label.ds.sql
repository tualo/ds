DELIMITER ;

INSERT  INTO `ds` (`table_name`, `title`, `reorderfield`, `use_history`, `searchfield`, `displayfield`, `sortfield`, `searchany`, `hint`, `overview_tpl`, `sync_table`, `writetable`, `globalsearch`, `listselectionmodel`, `sync_view`, `syncable`, `cssstyle`, `read_table`, `existsreal`, `class_name`, `special_add_panel`, `read_filter`, `listxtypeprefix`, `phpexporter`, `phpexporterfilename`, `combined`, `allowForm`, `alternativeformxtype`, `character_set_name`, `default_pagesize`, `listviewbaseclass`, `showactionbtn`) 
VALUES ('ds_preview_form_label','Vorschau','position',0,'column_name','column_name','position',1,'','','','',0,'cellmodel','',0,'','view_readtable_ds_preview_form_label_all',1,'Datenstamm','','','listview','XlsxWriter','{GUID}',0,0,'','',100,'Tualo.DataSets.ListView',1)


ON DUPLICATE KEY UPDATE
                    `title`=VALUES(`title`),
                    `reorderfield`=VALUES(`reorderfield`),
                    `use_history`=VALUES(`use_history`),
                    `searchfield`=VALUES(`searchfield`),
                    `displayfield`=VALUES(`displayfield`),
                    `sortfield`=VALUES(`sortfield`),
                    `searchany`=VALUES(`searchany`),
                    `hint`=VALUES(`hint`),
                    `overview_tpl`=VALUES(`overview_tpl`),
                    `sync_table`=VALUES(`sync_table`),
                    `writetable`=VALUES(`writetable`),
                    `globalsearch`=VALUES(`globalsearch`),
                    `listselectionmodel`=VALUES(`listselectionmodel`),
                    `sync_view`=VALUES(`sync_view`),
                    `syncable`=VALUES(`syncable`),
                    `cssstyle`=VALUES(`cssstyle`),
                    `alternativeformxtype`=VALUES(`alternativeformxtype`),
                    `read_table`=   VALUES(read_table),
                    `class_name`=VALUES(`class_name`),
                    `special_add_panel`=VALUES(`special_add_panel`),
                    `existsreal`=VALUES(`existsreal`),
                    `character_set_name`=VALUES(`character_set_name`),
                    `read_filter`=VALUES(`read_filter`),
                    `listxtypeprefix`=VALUES(`listxtypeprefix`),
                    `phpexporter`=VALUES(`phpexporter`),
                    `phpexporterfilename`=VALUES(`phpexporterfilename`),
                    `combined`=VALUES(`combined`),
                    `default_pagesize`=VALUES(`default_pagesize`),
                    `allowForm`=VALUES(`allowForm`),
                    `listviewbaseclass`=VALUES(`listviewbaseclass`),
                    `showactionbtn`=VALUES(`showactionbtn`),
                    `modelbaseclass`=VALUES(`modelbaseclass`)
;




INSERT IGNORE INTO `ds_column` (`table_name`, `column_name`, `default_value`, `default_max_value`, `default_min_value`, `is_primary`, `update_value`, `is_nullable`, `is_referenced`, `referenced_table`, `referenced_column_name`, `data_type`, `column_key`, `column_type`, `character_maximum_length`, `numeric_precision`, `numeric_scale`, `character_set_name`, `privileges`, `existsreal`, `deferedload`, `writeable`, `note`, `hint`) VALUES ('ds_preview_form_label','active','1',0,0,0,'','NO','NO','','','tinyint','','int(4)',NULL,10,0,NULL,'select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','column_name','',0,0,1,'','NO','NO','ds_column','column_name','varchar','PRI','varchar(255)',255,NULL,NULL,'utf8mb3','select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','editor','',10000000,0,0,'','NO','NO','','','varchar','','varchar(255)',255,NULL,NULL,'utf8mb3','select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','field_path','',0,0,0,'','NO','NO','','','varchar','','varchar(255)',255,NULL,NULL,'utf8mb3','select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','label','{column_name}',0,0,0,'','NO','NO','','','varchar','','varchar(255)',255,NULL,NULL,'utf8mb3','select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','language','DE',0,0,1,'','NO','NO','','','varchar','PRI','varchar(3)',3,NULL,NULL,'utf8mb3','select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','position','0',0,0,0,'','NO','NO','','','int','','int(11)',NULL,10,0,NULL,'select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','table_name','',0,0,1,'','NO','NO','ds_column','table_name','varchar','PRI','varchar(128)',128,NULL,NULL,'utf8mb3','select,insert,update,references',1,0,1,'',''),
('ds_preview_form_label','xtype','displayfield',0,0,0,'','NO','NO','','','varchar','','varchar(255)',255,NULL,NULL,'utf8mb3','select,insert,update,references',1,0,1,'','');

INSERT IGNORE INTO `ds_column_list_label` (`table_name`, `column_name`, `language`, `label`, `xtype`, `editor`, `position`, `summaryrenderer`, `summarytype`, `hidden`, `active`, `renderer`, `filterstore`, `flex`, `direction`, `align`, `grouped`, `listfiltertype`, `hint`) VALUES ('ds_preview_form_label','active','DE','Aktiv','checkcolumn','',6,'','',0,1,'','',1.00,'ASC','left',0,'',''),
('ds_preview_form_label','column_name','DE','Spalte','gridcolumn','',1,'','',0,1,'','',1.00,'ASC','left',0,'',''),
('ds_preview_form_label','field_path','DE','Pfad','gridcolumn','',3,'','',1,1,'','',1.00,'ASC','left',0,'',''),
('ds_preview_form_label','label','DE','Label','gridcolumn','textfield',4,'','',0,1,'','',1.00,'ASC','left',0,'',''),
('ds_preview_form_label','language','DE','Sprache','gridcolumn','',2,'','',1,1,'','',1.00,'ASC','left',0,'',''),
('ds_preview_form_label','position','DE','Position','gridcolumn','',7,'','',1,1,'','',1.00,'ASC','left',0,'',''),
('ds_preview_form_label','table_name','DE','Tabelle','gridcolumn','',0,'','',1,1,'','',1.00,'ASC','left',0,'',''),
('ds_preview_form_label','xtype','DE','Typ','gridcolumn','formxtype_combobox',5,'','',0,1,'','',1.00,'ASC','left',0,'','');

INSERT IGNORE INTO `ds_column_form_label` (`table_name`, `column_name`, `language`, `label`, `xtype`, `field_path`, `position`, `hidden`, `active`, `allowempty`, `fieldgroup`) VALUES ('ds_preview_form_label','active','DE','active','displayfield','Allgemein',7,1,1,1,''),
('ds_preview_form_label','column_name','DE','column_name','displayfield','Allgemein',1,1,1,1,''),
('ds_preview_form_label','field_path','DE','field_path','displayfield','Allgemein',6,1,1,1,''),
('ds_preview_form_label','label','DE','label','displayfield','Allgemein',3,0,1,1,''),
('ds_preview_form_label','language','DE','language','displayfield','Allgemein',2,1,1,1,''),
('ds_preview_form_label','position','DE','position','displayfield','Allgemein',5,1,1,1,''),
('ds_preview_form_label','table_name','DE','table_name','displayfield','Allgemein',0,1,1,1,''),
('ds_preview_form_label','xtype','DE','xtype','displayfield','Allgemein',4,0,1,1,'');

INSERT IGNORE INTO `ds_reference_tables` (`table_name`, `reference_table_name`, `columnsdef`, `active`, `constraint_name`, `searchable`, `autosync`, `position`, `path`) 
VALUES 
('ds_preview_form_label','ds','{\"ds_preview_form_label__table_name\":\"ds__table_name\"}',1,'fk_ds_preview_form_label_ds',0,1,99999,''),
('ds_preview_form_label','ds_column','{\"ds_preview_form_label__table_name\":\"ds_column__table_name\",\"ds_preview_form_label__column_name\":\"ds_column__column_name\"}',0,'',0,1,99999,''),
('ds_preview_form_label','ds_column','{\"ds_preview_form_label__table_name\":\"ds_column__table_name\",\"ds_preview_form_label__column_name\":\"ds_column__column_name\"}',0,'fk_ds_preview_form_label_ds_column',0,1,99999,'');

INSERT IGNORE INTO `ds_access` (`role`, `table_name`, `read`, `write`, `delete`, `append` ) VALUES ('administration','ds_preview_form_label',1,1,0,0 );
