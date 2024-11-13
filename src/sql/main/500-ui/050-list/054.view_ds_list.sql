delimiter ;

call addfieldifnotexists('ds_listplugins','placement','varchar(50) default "view"');

create or replace view view_ds_list_plugins as


    SELECT
        table_name,
        JSON_OBJECT(
            'ptype', 'cellediting',
            'clicksToEdit', 1,
            'id', concat(LOWER(table_name),'_cellediting')
        )   fld,
        'view' placement
    FROM 
        ds 
    where true

    union

    SELECT
        table_name,
        JSON_OBJECT(
            'ptype', 'gridfilters',
            'id', concat(LOWER(table_name),'_gridfilters')
        ) fld,
        'view' placement
    FROM 
        ds 
    -- where false

    union 

    SELECT
        table_name,
        JSON_OBJECT(
            'ptype', 'gridviewdragdrop',
            'id', concat(LOWER(table_name),'_gridviewdragdrop'),
            'dragText', 'Reihenfolge ändern',
            'reorderfield', concat(table_name,'__',reorderfield)
        ) fld,
        'viewConfig' placement
      FROM 
        ds 
      WHERE  
        ds.reorderfield<>'' 
        and ds.reorderfield is not null
        
      UNION

      SELECT
        ds_listplugins.table_name,
        JSON_OBJECT(
            'ptype', ds_listplugins.ptype,
            'id', concat(LOWER(ds_listplugins.table_name),'_',LOWER(ds_listplugins.ptype))
        ) fld,
        ds_listplugins.placement
      FROM 
        ds_listplugins 
;


create or replace view view_ds_list_plugins_grouped as
select
    table_name,
    placement,
    json_arrayagg(
            fld
    ) plugins
from 
    view_ds_list_plugins
group by table_name,placement
;

create or replace view view_ds_list as
select 
    concat(  'Tualo/DataSets/list/',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)),'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.list.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),',',

        if( extjs_base_types.id<>'Ext.grid.property.Grid',

            JSON_OBJECT(
                "extend", if( ifnull(extjs_base_types.id,"")='', 'Tualo.DataSets.grid.Grid', extjs_base_types.id),
                "tablename",  ds.table_name,
                "alias", concat('widget.dslist_',ds.table_name),
                "title", ds.title,
                
                "controller",concat('dsgridcontroller'),
                "stateful",JSON_OBJECT("columns",true),
                
                "selModel",ds.listselectionmodel,
                "features", JSON_ARRAY(
                    JSON_OBJECT(
                        "ftype", 'summary',
                        "dock", 'bottom'
                    ),
                    JSON_OBJECT(
                        "ftype","grouping"
                    )
                ),
                
                "plugins",  ifnull(viewPlugins.plugins,JSON_ARRAY()),
                
                "viewConfig",JSON_OBJECT(
                    'listeners', JSON_OBJECT(
                        'drop', 'onDropGrid'
                    ),
                    "plugins", ifnull(viewConfigPlugins.plugins,JSON_ARRAY())
                    
                ),
                
                "store", concat('ds_',ds.table_name),
                "columns",ifnull(JSON_MERGE('[]', view_ds_listcolumn.js),json_array())
                
            ),
            JSON_OBJECT(
                "extend", 'Ext.grid.property.Grid',
                "tablename",  ds.table_name,
                "alias", concat('widget.dslist_',ds.table_name),
                "title", ds.title,
                "store", concat('ds_',ds.table_name),
                "source", JSON_OBJECT("data",true,"time",'x'),
                "controller",concat('dsgridcontroller'),
                "stateful",JSON_OBJECT("columns",true),
                "selModel",ds.listselectionmodel
                
            )
        ),
    ')',char(59)) js,
    view_ds_listcolumn.js jsx,
    ds.table_name
from
    ds
    join view_ds_listcolumn 
        on ds.table_name = view_ds_listcolumn.table_name
    left join extjs_base_types
        on extjs_base_types.id = ds.listviewbaseclass
    left join view_ds_list_plugins_grouped viewConfigPlugins
        on viewConfigPlugins.table_name = ds.table_name
        and viewConfigPlugins.placement = 'viewConfig'
    left join view_ds_list_plugins_grouped viewPlugins
        on viewPlugins.table_name = ds.table_name
        and viewPlugins.placement = 'view'

where
    /*`ds`.`title`<>''*/ true;
