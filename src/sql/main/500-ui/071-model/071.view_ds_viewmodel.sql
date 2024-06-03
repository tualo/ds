delimiter ;

create or replace view view_ds_viewmodel as
select 
    concat(  'Tualo/DataSets/viewmodel/',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)),'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.viewmodel.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),',',
        JSON_OBJECT(
            "extend", "Tualo.DS.panel.Model",

            "alias", concat('viewmodel.dsview_',ds.table_name),
            "data", JSON_OBJECT(
                "record", null,
                "title", ds.title,
                "pagerText","",
                "selectRecordRecordNumber",0,
                "reorderfield",ds.reorderfield,
                "disableNext",true,
                "disablePrev",  true,
                "isModified",false,
                "hideList",false,
                "isNew",false,
                "table_name",ds.table_name
            )
        ),
    ')',char(59)) js,
    view_ds_listcolumn.js jsx,
    ds.table_name
from
    ds
    join view_ds_listcolumn 
        on ds.table_name = view_ds_listcolumn.table_name

where
    `ds`.`title`<>'';