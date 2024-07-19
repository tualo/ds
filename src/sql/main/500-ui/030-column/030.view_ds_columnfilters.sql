delimiter ;
create or replace view view_ds_columnfilters as
select 
    concat(  'Tualo/DataSets/grid/filters/filter/',lower(ds_dropdownfields.table_name),'/',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ,'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.grid.filters.filter.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  )),',',
            JSON_OBJECT(
                 "extend",  "Tualo.grid.filters.List",
                -- "extend", "Ext.grid.filters.filter.List",
                "alias", concat('grid.filter.',lower(concat(ds_dropdownfields.table_name,'_',ds_dropdownfields.name,'_listfilter'))),
                "tablename", `ds_dropdownfields`.`table_name`,
                "idField", lower( concat( /*`ds_dropdownfields`.`table_name`,'__',*/ `ds_dropdownfields`.`idfield` )),
                "labelField", lower( concat( /*`ds_dropdownfields`.`table_name`,'__',*/ `ds_dropdownfields`.`displayfield` )),
                "store", JSON_OBJECT(
                    "type", concat('ds_',`ds_dropdownfields`.`table_name`),
                    "storeId", concat('ds_',`ds_dropdownfields`.`table_name`,'_store'),
                    "pageSize", 1000000
                )
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