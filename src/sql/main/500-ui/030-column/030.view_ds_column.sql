delimiter ;

create or replace view view_ds_column as
select 

    concat(  'Tualo/DataSets/column/',lower(ds_dropdownfields.table_name),'/',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ,'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.column.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  )),',',
            
            JSON_OBJECT(
                "extend",  "Tualo.cmp.cmp_ds.column.DS",
                -- "requires", JSON_MERGE('[]',concat('[',doublequote(concat('Tualo.DataSets.store.',UCASE(LEFT(ds_dropdownfields.table_name, 1)), lower(SUBSTRING(ds_dropdownfields.table_name, 2)))),']')) ,
                "tablename", `ds_dropdownfields`.`table_name`,
                "idField", lower(ds_dropdownfields.idfield),
                "displayField", lower(ds_dropdownfields.displayfield),
                "configStore", JSON_OBJECT(
                    "type", concat('ds_',`ds_dropdownfields`.`table_name`),
                    "storeId", concat('ds_',`ds_dropdownfields`.`table_name`,'_columnstore'),
                    "pageSize", 1000000
                ),
                "alias", concat('widget.column_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name))
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


create or replace view view_ds_column_stores as
select  ds_column_list_label.table_name,JSON_ARRAYAGG(

    distinct JSON_OBJECT(
        "type", x.store_type,
        "storeId", x.store_id,
        "pageSize", 1000000
    )
) stores  from 
	ds_column_list_label 
    join ( select 
	concat('column_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) id,
	concat('ds_',`ds_dropdownfields`.`table_name`) store_type,
    concat('ds_',`ds_dropdownfields`.`table_name`,'_columnstore') store_id,
	`ds_dropdownfields`.`table_name`,
    `ds_dropdownfields`.`name`
from
    `ds_dropdownfields`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1
where
    `ds_dropdownfields`.`name`<>'' ) x
    on ds_column_list_label.xtype=x.id
group by ds_column_list_label.table_name;