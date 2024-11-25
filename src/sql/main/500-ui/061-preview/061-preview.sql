delimiter ;

CREATE TABLE IF NOT EXISTS `ds_preview_form_label` (
  `table_name` varchar(128) NOT NULL,
  `column_name` varchar(64) NOT NULL,
  `language` varchar(3) NOT NULL DEFAULT 'DE',
  `label` varchar(255) NOT NULL,
  `xtype` varchar(255) DEFAULT NULL,
  `field_path` varchar(255) NOT NULL DEFAULT '',
  `position` int(11) DEFAULT 0,
  `active` tinyint(4) DEFAULT 1,
  `editor` varchar(100) DEFAULT NULL,
  `dockposition` varchar(20) DEFAULT 'left',
  PRIMARY KEY (`table_name`,`column_name`,`language`),
  CONSTRAINT `fk_ds_preview_form_label_ds` FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) ON DELETE CASCADE ON UPDATE CASCADE
);


call addFieldIfNotExists(
    "ds_preview_form_label",
    "dockposition",
    "varchar(20) DEFAULT 'left'"
);


create or replace view view_ds_preview as

select 
table_name,
JSON_ARRAYAGG(
    JSON_OBJECT(
        "xtype", "form",
        "title", "Vorschau",
        "bodyPadding", 12,
        "collapsible", 1=1,
        "scrollable", 1=1,
        "resizable",1=1,
        "widtXh", 250,
        "maxWidthX", 250,
        "dock", dockposition,
        "items", jsfield
    )
) js
from (
select
    `ds_preview_form_label`.`table_name`, 
    `ds_preview_form_label`.`column_name`,
    `ds_preview_form_label`.`field_path`,
    `ds_preview_form_label`.`dockposition`,
    `ds_preview_form_label`.`active`,
    `ds_preview_form_label`.`position`,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'fieldLabel', `ds_preview_form_label`.`label`,
            'flex', 1,
            'labelAlign','top',
            'tablename', `ds_preview_form_label`.`table_name`,
            'xtype',  
                if(view_readtable_all_types_modern.type is null,
                    'missedxtypefield', `ds_preview_form_label`.`xtype`
            ),

            'missedXtype', if(view_readtable_all_types_modern.type is null,`ds_preview_form_label`.`xtype`,''),
            

            'placeholder', `ds_preview_form_label`.`label`,
            'name', concat(  `ds_preview_form_label`.`column_name`),
            'bind', JSON_OBJECT( 
                "value",concat('{record.', `ds_preview_form_label`.`column_name`,'}')
            )
                
        )
        order by `ds_preview_form_label`.`position`
    ) jsfield

from 
    
    ds_preview_form_label
    

    left join view_readtable_all_types_classic view_readtable_all_types_modern
         on  view_readtable_all_types_modern.type = `ds_preview_form_label`.`xtype`
         and typeclass='widget'
where ds_preview_form_label.active = 1
group by 

    `ds_preview_form_label`.`table_name`, 
    `ds_preview_form_label`.`field_path`,
    `ds_preview_form_label`.`dockposition` 
) x  group by table_name;
