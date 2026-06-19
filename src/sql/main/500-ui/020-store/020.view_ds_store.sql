delimiter ;

alter table ds add column if not exists autosave tinyint(1) default 0;
alter table ds add column if not exists base_store_class varchar(50) default 'Tualo.DataSets.data.Store';




alter table ds add column if not exists sortdirection varchar(10) default 'ASC';




create or replace view view_ds_store_groupers as
select 
ds.table_name,
if( count(distinct ds_column_list_label.column_name )>0, JSON_ARRAYAGG(
    json_object(
        "property", ds_column_list_label.column_name,
        "sortProperty",ds.sortfield,

        "direction", if(ds.sortdirection<>'',ds.sortdirection,'ASC')
    )
),json_array()) groupers
 from 
    ds
    join ds_column
        on ds_column.table_name = ds.table_name
        and ds_column.existsreal=1
    left join ds_column_list_label 
        on ds.table_name = ds_column_list_label.table_name
        and ds_column_list_label.grouped=1
 
group by ds.table_name 

;

create or replace view view_ds_store as
select 
    concat('Tualo.DataSets.store.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2))) name,
    concat('Tualo/DataSets/store/',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)),'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.store.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),',',
        JSON_OBJECT(
            "extend",  if(ifnull(ds.base_store_class,'')='','Tualo.DataSets.data.Store', ds.base_store_class),
            "tablename", ds.table_name,
            "alias", JSON_ARRAY( concat('store.ds_',ds.table_name) ,concat('store.',ds.table_name,'_store') ),
            "storeId", concat('ds_',ds.table_name),
            -- "requires", JSON_MERGE('[]', if( suppressRequires() ,  '[]', concat('[',doublequote(concat('Tualo.DataSets.model.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),']')) ),
            "model", concat('Tualo.DataSets.model.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2))),
            "remoteFilter", TRUE is true,
            "autoLoad", FALSE is true,
            "autoSync", ds.autosave=1,
            "pageSize", ifnull(ds.default_pagesize,1000),
            "proxy", json_object(
                "type", 'tualo_datasets_json',
                "noCache", 1=0,
                "tablename",ds.table_name,
                "api", json_object(
                    "create", concat('./ds/',ds.table_name,'/create'),
                    "read", concat('./ds/',ds.table_name,'/read'),
                    "update", concat('./ds/',ds.table_name,'/update'),
                    "destroy", concat('./ds/',ds.table_name,'/delete')
                ),
                "reader", json_object(
                    "type", 'json',
                    "rootProperty", 'data',
                    "idProperty", '__id',
                    "clientIdProperty", '__clientid'
                ),
                "listeners", json_object(
                    "scope", 'this',
                    "exception", 'onStoreProxyExecption'
                )

            ),
            "sorters", JSON_ARRAY(
                JSON_OBJECT(
                    "property", if(ds.sortfield<>'',ds.sortfield,'__id'),
                    "direction", if(ds.sortdirection<>'',ds.sortdirection,'ASC')
                )
            ),
            "groupers", view_ds_store_groupers.groupers
        ),')',char(59)
    ) js,
    ds.table_name
from
    ds
    join view_ds_store_groupers
        on view_ds_store_groupers.table_name = ds.table_name
where
    /*`ds`.`title`<>'' and*/ (ds.table_name in (
        select 
            table_name
        from 
            ds_column 
        where `ds_column`.`existsreal`=1 
        -- and (`ds_column`.table_name, `ds_column`.column_name) in (select table_name, column_name from ds_column_list_label where active=1)
    ))
;