delimiter;


LOCK TABLES `ds` WRITE;
INSERT INTO `ds` (`table_name`, `title`, `reorderfield`, `use_history`, `searchfield`, `displayfield`, `sortfield`, `searchany`, `hint`, `overview_tpl`, `sync_table`, `writetable`, `globalsearch`, `listselectionmodel`, `sync_view`, `syncable`, `cssstyle`, `alternativeformxtype`, `read_table`, `class_name`, `special_add_panel`, `existsreal`, `character_set_name`, `read_filter`, `listxtypeprefix`, `phpexporter`, `phpexporterfilename`, `combined`, `default_pagesize`, `allowForm`, `listviewbaseclass`, `showactionbtn`, `modelbaseclass`) VALUES ('ds_listplugins','DS-Plugins','',0,'ptype','ptype','ptype',1,'','','','',0,'rowmodel','',0,'','','','Datenstamm','',1,'','','listview','XlsxWriter','',0,100,0,'Tualo.DataSets.ListView',1,'Tualo.DataSets.model.Basic')
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
                    `read_table`=   "view_pwgen_wahlberechtigte_anlage",
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
UNLOCK TABLES;
LOCK TABLES `ds_column` WRITE;
INSERT IGNORE INTO `ds_column` (`table_name`, `column_name`, `default_value`, `default_max_value`, `default_min_value`, `update_value`, `is_primary`, `syncable`, `referenced_table`, `referenced_column_name`, `is_nullable`, `is_referenced`, `writeable`, `note`, `data_type`, `column_key`, `column_type`, `character_maximum_length`, `numeric_precision`, `numeric_scale`, `character_set_name`, `privileges`, `existsreal`, `deferedload`, `hint`, `fieldtype`) VALUES ('ds_listplugins','placement','view',0,0,'',0,0,'','','YES','NO',1,'','varchar','','varchar(50)',50,0,0,'utf8mb4','select,insert,update,references',1,0,'',''),
('ds_listplugins','ptype',NULL,10000000,0,NULL,1,0,NULL,NULL,'NO','NO',1,'','varchar','PRI','varchar(255)',255,NULL,NULL,'utf8mb4','select,insert,update,references',1,0,NULL,''),
('ds_listplugins','table_name',NULL,10000000,0,NULL,1,0,NULL,NULL,'NO','NO',1,'','varchar','PRI','varchar(128)',128,NULL,NULL,'utf8mb4','select,insert,update,references',1,0,NULL,'');
UNLOCK TABLES;
LOCK TABLES `ds_column_list_label` WRITE;
INSERT IGNORE INTO `ds_column_list_label` (`table_name`, `column_name`, `language`, `label`, `xtype`, `editor`, `position`, `summaryrenderer`, `renderer`, `summarytype`, `hidden`, `active`, `filterstore`, `grouped`, `flex`, `direction`, `align`, `listfiltertype`, `hint`) VALUES ('ds_listplugins','placement','DE','Plugin-Stelle','gridcolumn',NULL,2,'','','',0,1,'',0,1.00,'ASC','left','',NULL),
('ds_listplugins','ptype','DE','P-Type','gridcolumn','',1,'','','',0,1,'',0,1.00,'ASC','left','',NULL),
('ds_listplugins','table_name','DE','Tabelle','gridcolumn','',0,'','','',0,1,'',0,1.00,'ASC','left','',NULL);
UNLOCK TABLES;
LOCK TABLES `ds_column_form_label` WRITE;
INSERT IGNORE INTO `ds_column_form_label` (`table_name`, `column_name`, `language`, `label`, `xtype`, `field_path`, `position`, `hidden`, `active`, `allowempty`, `fieldgroup`, `flex`, `hint`) VALUES ('ds_listplugins','placement','DE','Plugin-Stelle','textfield','Allgemein/Angaben',2,0,1,1,'',1.00,'\'\''),
('ds_listplugins','ptype','DE','P-Type','textfield','Allgemein/Angaben',1,0,1,1,'',1.00,'\'\''),
('ds_listplugins','table_name','DE','Tabelle','combobox_ds_tabelle','Allgemein/Angaben',0,0,1,1,'',1.00,'\'\'');
UNLOCK TABLES;
LOCK TABLES `ds_dropdownfields` WRITE;
UNLOCK TABLES;
LOCK TABLES `ds_reference_tables` WRITE;
INSERT IGNORE INTO `ds_reference_tables` (`table_name`, `reference_table_name`, `columnsdef`, `constraint_name`, `active`, `searchable`, `autosync`, `position`, `path`, `existsreal`, `tabtitle`) VALUES ('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,1,99999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,1,99999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,1,99999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,1,99999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,1,99999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"ds_listplugins__table_name\":\"ds__table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',0,''),
('ds_listplugins','ds','{\"table_name\":\"table_name\"}','fk_ds_listplugins_ds',0,0,0,999,'',1,'');
UNLOCK TABLES;
LOCK TABLES `ds_addcommands` WRITE;
UNLOCK TABLES;
LOCK TABLES `ds_access` WRITE;
INSERT IGNORE INTO `ds_access` (`role`, `table_name`, `read`, `write`, `delete`, `append`, `existsreal`) VALUES ('administration','ds_listplugins',1,1,1,1,0);
UNLOCK TABLES;

