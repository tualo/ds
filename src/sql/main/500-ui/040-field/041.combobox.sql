delimiter ;

create or replace view view_ds_combobox as
select 
    concat(  'Tualo/DataSets/combobox/',lower(ds_dropdownfields.table_name),'/',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ,'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.combobox.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  )),',',
            JSON_OBJECT(
                "extend",  "Tualo.cmp.cmp_ds.field.ComboBoxDS",
                -- "requires", JSON_MERGE('[]',concat('[',doublequote(concat('Tualo.DataSets.store.',UCASE(LEFT(ds_dropdownfields.table_name, 1)), lower(SUBSTRING(ds_dropdownfields.table_name, 2)))),']')) ,
                "tablename", `ds_dropdownfields`.`table_name`,
                "valueField", lower( concat( /*`ds_dropdownfields`.`table_name`,'__',*/ `ds_dropdownfields`.`idfield` )),
                "displayField", lower( concat( /*`ds_dropdownfields`.`table_name`,'__',*/ `ds_dropdownfields`.`displayfield` )),
                "store", JSON_OBJECT(
                    "type", concat('ds_',`ds_dropdownfields`.`table_name`,'_',ds_dropdownfields.name),
                    "storeId", concat('ds_',`ds_dropdownfields`.`table_name`,'_',ds_dropdownfields.name,'_columnstore'),
                    "pageSize", 10000000,
                    "remoteFilter", 0=1,
                    "proxy",
                    json_object(
                        "type", 'ajax',
                        "noCache", 1=0,
                        "tablename",ds_dropdownfields.table_name,
                        "api", json_object(
                            "create", concat('./ds/',ds_dropdownfields.table_name,'/create'),
                            "read", concat('./ds/',ds_dropdownfields.table_name,'/read'),
                            "update", concat('./ds/',ds_dropdownfields.table_name,'/update'),
                            "destroy", concat('./ds/',ds_dropdownfields.table_name,'/delete')
                        ),
                        "extraParams", json_object(
                            "fields", concat('["',ds_dropdownfields.displayfield,'","',ds_dropdownfields.idfield,'"]')
                        ),

                        "reader", json_object(
                            "type", 'json',
                            "rootProperty", 'data',
                            "idProperty", ds_dropdownfields.idfield,
                            "clientIdProperty", ds_dropdownfields.idfield
                        )

                    )
                ),
                "alias", concat('widget.combobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name))
            ),
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




-- select * from view_ds_column;