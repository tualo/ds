delimiter ;

create or replace view view_ds_dsview_accordion as
select 
    ds.table_name,
    JSON_OBJECT(
        "title", ifnull(concat('Liste (',ds.title,')'),"Liste"),
        "iconCls", "x-fa fa-th",
        "xtype", concat("dslist_",ds.table_name),


        
        "selModel", if(ifnull(ds.listselectionmodel,'')='','rowmodel',ds.listselectionmodel),
        "store", JSON_OBJECT(
            "type", concat("",ds.table_name,"_store"),
            "autoLoad", 1=0,
            "listeners", JSON_OBJECT(
                "sync", "onSyncStore"
            )
        ),
        "listeners", JSON_OBJECT(
            "drop", "onDropGrid",
            "itemdblclick", 'onItemDblClick'
        ),
        "itemId", "list"
    ) js,
    1000000 position
from ds
union
select
    ds.table_name,
    JSON_OBJECT(
        
        "iconCls", "x-fa fa-clone",
        "bind", JSON_OBJECT(
                -- "store", "{list}",
                "disabled", "{!record}",
                "title", "{currentTitle}"
                -- ifnull(concat('Formular (',ds.title,') {record.__displayfield}'),"Formular")
                -- "selection", "{record}"
        ),
        "xtype", 
            if(
                alternativeformxtype is null or alternativeformxtype = '',
                concat("dsform_",ds.table_name),
                alternativeformxtype
            )
        ,
        "itemId", "form",
         "listeners", JSON_OBJECT(
            "expand", 'onFormExpand'
        )
    ),
    2000000 position
from ds

-- cmp_belege_report_editorform

union 
SELECT
    table_name,
    JSON_OBJECT(
        "iconCls", "x-fa fa-file-pdf",
        "xtype", "cmp_ds_pdfrendererpanel",
        "bind", JSON_OBJECT(
            "record", "{record}"
        ),
        "border", 1=0,
        "title",`label`,
        "template",pug_template,
        "useremote", useremote
    ) js,
    3000000 position
FROM ds_renderer 
;


call addfieldifnotexists('ds_addcommands','iconCls','varchar(255) default "x-fa fa-plus"');
create or replace view view_ds_dsview_commands as
select 
ds_addcommands.table_name,
ds_addcommands.location,
ds_addcommands.position,
JSON_OBJECT(
    'text', ds_addcommands.label,
    'iconCls', ifnull(ds_addcommands.iconcls,'x-fa fa-plus'),
    'defered', ds_addcommands.xtype,
    'handler', 'onAddCommandClick'
) js

from ds_addcommands
where ds_addcommands.location = 'toolbar';

create or replace view view_ds_dsview as
select 
    concat(  'Tualo/DataSets/dsview/',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)),'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.dsview.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),',',
        JSON_OBJECT(
            "extend", "Tualo.DS.Panel",
            "alias", concat('widget.dsview_',ds.table_name),
            "title", null, -- ds.title,
            "tablename", ds.table_name,

            "controller",concat('dsview_',ds.table_name),
            "viewModel", JSON_OBJECT(
                "type",  concat('dsview_',ds.table_name)
            ),

            "listeners", JSON_OBJECT(
                "boxready", 'onBoxReady'
            ),
            
            "layout", JSON_OBJECT(
                "type", 'accordion',
                "vertical",  1=0,
                "titleCollapse", 1=1,
                "animate", 1=1,
                "activeOnTop", 1=0
            ),
            
            "statics", JSON_OBJECT(
                "stores", view_ds_column_stores.stores,
                "globalsearch", JSON_OBJECT(
                    "title", ifnull(ds.title,'not set'),
                    "table_name", ds.table_name,
                    "loadClass", concat('Tualo.DataSets.dsview.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2))),
                    "hint", ds.hint,
                    "iconCls", "x-fa fa-search",
                    "routeTo", concat("ds/",ds.table_name)
                )
            ),
            "defaults", JSON_OBJECT(
                "headerPosition", "left"
            ),
            "additionalTools", if (
                view_ds_dsview_commands.js is null, 
                    json_merge(json_array(),'[]'), 
                    json_merge(ifnull(JSON_ARRAYAGG(
                        distinct 
                        view_ds_dsview_commands.js
                order by view_ds_dsview_commands.position
            ),'[]'),'[]')),
            "items", JSON_ARRAYAGG(
                distinct
                view_ds_dsview_accordion.js
                order by view_ds_dsview_accordion.position
            ),
            "dockedItems",  
            if(view_ds_preview.js is null ,json_object('xtype','dstoolbar'), 
                json_merge(view_ds_preview.js,json_object('xtype','dstoolbar'))
            )
        )
    ,')',char(59)) js,
    ds.table_name
from ds
    join view_ds_dsview_accordion 
        on view_ds_dsview_accordion.table_name=ds.table_name
    left join view_ds_column_stores on ds.table_name = view_ds_column_stores.table_name
    left join view_ds_dsview_commands on ds.table_name = view_ds_dsview_commands.table_name
        and view_ds_dsview_commands.location = 'toolbar'
    left join view_ds_preview
        on view_ds_preview.table_name = ds.table_name
group by ds.table_name
;


