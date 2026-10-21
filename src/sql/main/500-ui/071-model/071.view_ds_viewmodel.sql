delimiter ;

alter table ds add column if not exists list_on_append tinyint default 0;
alter table ds add column if not exists form_on_double_click tinyint default 1;
-- update ds set list_on_append=1 where table_name='tualo_job_data';
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
                "listOnAppend", ds.list_on_append,
                "formOnDoubleClick", ds.form_on_double_click,
                "table_name",ds.table_name,
                "contextmenu", ifnull(view_ds_contextmenu.contextmenu, JSON_ARRAY())
            )
            
        ),
    ')',char(59)) js,
    view_ds_listcolumn.js jsx,
    ds.table_name
from
    ds
    join view_ds_listcolumn 
        on ds.table_name = view_ds_listcolumn.table_name
    left join view_ds_contextmenu
        on ds.table_name = view_ds_contextmenu.table_name
where
    `ds`.`title`<>'';