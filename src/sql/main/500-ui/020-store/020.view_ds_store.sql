delimiter ;

alter table ds add column if not exists autosave tinyint(1) default 0;
create or replace view view_ds_store as
select 
    concat('Tualo.DataSets.store.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2))) name,
    concat('Tualo/DataSets/store/',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)),'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.store.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),',',
        JSON_OBJECT(
            "extend",  "Tualo.DataSets.data.Store",
            "tablename", table_name,
            "alias", JSON_ARRAY( concat('store.ds_',table_name) ,concat('store.',table_name,'_store') ),
            "storeId", concat('ds_',table_name),
            -- "requires", JSON_MERGE('[]', if( suppressRequires() ,  '[]', concat('[',doublequote(concat('Tualo.DataSets.model.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),']')) ),
            "model", concat('Tualo.DataSets.model.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2))),
            "remoteFilter", TRUE is true,
            "autoLoad", FALSE is true,
            "autoSync", ds.autosave=1,
            "pageSize", ifnull(ds.default_pagesize,1000),
            "sorters", JSON_ARRAY(
                JSON_OBJECT(
                    "property", if(sortfield<>'',sortfield,'__id'),
                    "direction", "ASC"
                )
            )
        ),')',char(59)
    ) js,
    table_name
from
    ds
    
where
    /*`ds`.`title`<>'' and*/ (table_name in (
        select 
            table_name
        from 
            ds_column 
        where `ds_column`.`existsreal`=1 
        -- and (`ds_column`.table_name, `ds_column`.column_name) in (select table_name, column_name from ds_column_list_label where active=1)
    ))
;