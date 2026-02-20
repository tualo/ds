delimiter ;

create or replace view view_ds_field_store as
select 
    concat('Tualo.DataSets.store.',append_name) name,
    concat('Tualo/DataSets/store/',append_name,'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.store.',append_name)),',',
        JSON_OBJECT(
            "extend",  if(ifnull(ds.base_store_class,'')='','Tualo.DataSets.data.Store', ds.base_store_class),
            "tablename", view_ds_field_model.table_name,
            "alias", JSON_ARRAY( concat('store.ds_',view_ds_field_model.table_name,'_',shortname) ,concat('store.',view_ds_field_model.table_name,'_',shortname,'_store') ),
            "storeId", concat('ds_',view_ds_field_model.table_name,'_',shortname),
            "model", view_ds_field_model.name,
            "remoteFilter", 0=1,
            "autoLoad", FALSE is true,
            "autoSync", 0=1,
            "pageSize", 1000000,
            "proxy",
            json_object(
                "type", 'ajax',
                "noCache", 1=0,
                "tablename",ds.table_name,
                "api", json_object(
                    "create", concat('./ds/',view_ds_field_model.table_name,'/create'),
                    "read", concat('./ds/',view_ds_field_model.table_name,'/read'),
                    "update", concat('./ds/',view_ds_field_model.table_name,'/update'),
                    "destroy", concat('./ds/',view_ds_field_model.table_name,'/delete')
                ),
                "extraParams", json_object(
                    "fields", concat('["',view_ds_field_model.displayfield,'","',view_ds_field_model.idfield,'"]')
                ),

                "reader", json_object(
                    "type", 'json',
                    "rootProperty", 'data',
                    "idProperty", view_ds_field_model.idfield,
                    "clientIdProperty", view_ds_field_model.idfield
                )

            ),
            "sorters", JSON_ARRAY(
                JSON_OBJECT(
                    "property", view_ds_field_model.displayfield,
                    "direction", if(sortdirection<>'',sortdirection,'ASC')
                )
            )
        ),')',char(59)
    ) js,
    view_ds_field_model.table_name
from
    ds
    join view_ds_field_model
        on ds.table_name = view_ds_field_model.table_name
    
where
    /*`ds`.`title`<>'' and*/ (view_ds_field_model.table_name in (
        select 
            table_name
        from 
            ds_column 
        where `ds_column`.`existsreal`=1 
        -- and (`ds_column`.table_name, `ds_column`.column_name) in (select table_name, column_name from ds_column_list_label where active=1)
    ))
;