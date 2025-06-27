delimiter ;

create
or replace view view_ds_formfields as
select
    JSON_MERGE(
        '[]',
        concat(
            '[',
            group_concat(
                `ds_column_form_label`.`jsfield`
                order by
                    `ds_column_form_label`.`position` separator ','
            ),
            ']'
        )
    ) js,
    `ds`.`table_name`,
    min(ds_column_form_label.position) position,
    SUBSTRING_INDEX(field_path, '/', 1) tab_title,
    SUBSTRING_INDEX(field_path, '/', -1) fieldset_title,
    group_concat(
        `ds_column`.`column_name` separator ','
    ) cols
from
    `ds`
    join `ds_column` on `ds`.`table_name` = `ds_column`.`table_name`
    and `ds_column`.`existsreal` = 1
    and `ds`.`title` <> ''
    join view_ds_formfieldgroups `ds_column_form_label` on (
        `ds_column`.`table_name`,
        `ds_column`.`column_name`
    ) = (
        `ds_column_form_label`.`table_name`,
        `ds_column_form_label`.`column_name`
    )
    and `ds_column_form_label`.`active` = 1
group by
    `ds`.`table_name`,
    SUBSTRING_INDEX(field_path, '/', 1),
    SUBSTRING_INDEX(field_path, '/', -1);

create
or replace view view_ds_formtabs_fieldsets as
select
    `ds_column_form_label`.`table_name`,
    `view_ds_formfields`.`tab_title`,
    group_concat(
        distinct `view_ds_formfields`.`cols` separator ' | '
    ) cols,
    min(ds_column_form_label.position) min_position,
    json_arrayagg(
        distinct 
        JSON_OBJECT(
            "xtype",
            "fieldset",
            /*
            "layout",
            'anchor',
            */
            "title",
            `view_ds_formfields`.`fieldset_title`,
            "defaults",
            JSON_OBJECT("anchor", "100%"),
            --            "scrollable", "y",
            "items",
            JSON_MERGE('[]', `view_ds_formfields`.`js`)
        )
        order by
            view_ds_formfields.position  
    ) js
from
    `ds_column_form_label`
    join `view_ds_formfields` on `ds_column_form_label`.`table_name` = `view_ds_formfields`.`table_name`
    and SUBSTRING_INDEX(ds_column_form_label.`field_path`, '/', 1) = `view_ds_formfields`.`tab_title`
    and SUBSTRING_INDEX(ds_column_form_label.`field_path`, '/', -1) = `view_ds_formfields`.`fieldset_title`
    and `ds_column_form_label`.`active` = 1
group by
    `ds_column_form_label`.`table_name`,
    `view_ds_formfields`.`tab_title`
order by
    min_position;

create or replace view view_ds_formtabs as

    select
        `ds_column_form_label`.`table_name`,
        JSON_OBJECT(
            "xtype", "tualodsform",
            "title",  `view_ds_formtabs_fieldsets`.`tab_title` ,
            "padding",  12,
            "scrollable",  "y",
            "items", JSON_MERGE('[]', `view_ds_formtabs_fieldsets`.`js`)
        ) js,
        min(ds_column_form_label.position) position
    from
        `ds_column_form_label`
        join `view_ds_formtabs_fieldsets` on 
        
        `ds_column_form_label`.`table_name` = `view_ds_formtabs_fieldsets`.`table_name`
        and SUBSTRING_INDEX(`field_path`, '/', 1) = `view_ds_formtabs_fieldsets`.`tab_title`
        and `ds_column_form_label`.`active` = 1
    group by
        `ds_column_form_label`.`table_name`,
        `view_ds_formtabs_fieldsets`.`tab_title`



union
select
    ds_reference_tables.reference_table_name `table_name`,
    JSON_OBJECT(
        "title",
        if(
            ifnull(ds_reference_tables.tabtitle, '') = '',
            ds.title,
            ds_reference_tables.tabtitle
        ),
        "xtype",
        concat('dsview_', ds_reference_tables.table_name),
        "referencedList",
        1 = 1,
        "referencedXType",
        concat(
            'dsview_',
            ds_reference_tables.reference_table_name
        ),
        "referenced",
        JSON_MERGE('{}', replace(replace(ds_reference_tables.columnsdef,concat('"',ds_reference_tables.reference_table_name,'__'),'"'),concat('"',ds_reference_tables.table_name,'__'),'"'))
    ) js,
    100 + ds_reference_tables.position
from
    ds_reference_tables
    join ds on ds.table_name = ds_reference_tables.table_name
where
    ds_reference_tables.active = 1
    and ds.title <> ''
union
select
    adress_bezug table_name,
    JSON_OBJECT(
        "title", blg_config.name,
        "xtype", concat( 'dsview_', 'view_blg_list_', lower(blg_config.tabellenzusatz) ),
        -- "html", concat( 'dsview_', 'view_blg_list_', lower(blg_config.tabellenzusatz) ),
        "referencedList", 1 = 1,
        "referenced", JSON_OBJECT(
            concat( 'kundennummer' ),
            concat( blg_config.bezug_id),
            concat( 'kostenstelle' ),
            concat( bezug_kst)
        )
    ) js,
    9000000+(rank() over (order by blg_config.name)) position
from
    blg_config
where
    bezug_anzeigen = 1;

create
or replace view view_ds_formtabs_pertable as
select
    `view_ds_formtabs`.`table_name`,
    JSON_MERGE(
        '[]',
        concat(
            '[',
            /*JSON_OBJECT('xtype','tabbar','docked','top','activeItem',0),
             ',', */
            group_concat(
                view_ds_formtabs.js
                order by
                    view_ds_formtabs.position separator ','
            ),
            ']'
        )
    ) js
from
    view_ds_formtabs
group by
    `view_ds_formtabs`.`table_name`;

-- select * from view_ds_formtabs_pertable where table_name='adressen';