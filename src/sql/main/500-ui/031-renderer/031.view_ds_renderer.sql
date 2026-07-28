delimiter ;
/*
Ext.define("Tualo.ds.DSRenderZ2", {
    extend: 'Tualo.ds.DSRender',
    singleton: true,
    config: {
        table_name: 'artikelgruppen',
        idField: 'gruppen_id',
        displayField: 'kurztext',
    }
});
*/
create or replace view view_ds_renderer as
select 

    concat(  'Tualo/DataSets/renderer/',lower(ds_dropdownfields.table_name),'/',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ,'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.renderer.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  )),',',
            
            JSON_OBJECT(
                "extend",  "Tualo.ds.renderer.DS",
                "singleton", 1=1,
                "config"    ,JSON_OBJECT(
                    "table_name", `ds_dropdownfields`.`table_name`,
                    "name", lower(ds_dropdownfields.name),
                    "idField", lower(ds_dropdownfields.idfield),
                    "displayField", lower(ds_dropdownfields.displayfield)
                )
            )
        ')',char(59)
    ) js,
    `ds_dropdownfields`.`table_name`,
    `ds_dropdownfields`.`name`
from
    `ds_dropdownfields`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1
where
    `ds_dropdownfields`.`name`<>''
;
