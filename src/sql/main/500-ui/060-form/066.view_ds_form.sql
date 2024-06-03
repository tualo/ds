delimiter ;


create or replace view view_ds_form_requires as
select 
        ds_reference_tables.reference_table_name `table_name`,
        JSON_ARRAYAGG( concat('Tualo.DataSets.form.',UCASE(LEFT(ds_reference_tables.table_name, 1)), lower(SUBSTRING(ds_reference_tables.table_name, 2)))) requires
from 
        ds_reference_tables 
where 
        ds_reference_tables.active=1
group by ds_reference_tables.reference_table_name
;

create or replace view view_ds_form as
select 
    concat(  'Tualo/DataSets/form/',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)),'.js') filename,
    concat(
        'Ext.define(',doublequote(concat('Tualo.DataSets.form.',UCASE(LEFT(ds.table_name, 1)), lower(SUBSTRING(ds.table_name, 2)))),',',

        JSON_OBJECT(
            "extend", "Tualo.DS.form.Form",
            "tablename",ds.table_name,
            "alias", concat('widget.dsform_',ds.table_name),
            "config", JSON_OBJECT(
                "title", ds.title
            ),
            "layout", JSON_OBJECT(
                "type", 'hbox',
                "align", 'stretch'
            ),
            "items", 
            JSON_OBJECT(
                "xtype", "tabpanel",
                "flex", 1,
                
                "items",  JSON_MERGE('[]',ifnull(  view_ds_formtabs_pertable.js, '[]' ))
                
            )
        ),
    ')',char(59)) js,
    view_ds_formtabs_pertable.js jsx,
    ds.table_name
from
    ds
    left join view_ds_form_requires 
        on ds.table_name = view_ds_form_requires.table_name
    left join view_ds_formtabs_pertable 
        on ds.table_name = view_ds_formtabs_pertable.table_name
    left join (
        select 
            ds_column_form_label.table_name,
            concat('[',
                    group_concat(
                        distinct 
                        concat('"',view_readtable_all_types_modern.id,'"')
                        separator ','
                    ),
                ']'
            ) `requiresJS`
        from 
            (
                select 
                    table_name,
                    column_name,
                    language,
                    label,
                    xtype,
                    field_path,
                    position,
                    hidden,
                    active,
                    allowempty,
                    concat( 
                        table_name,
                        if(fieldgroup is null or fieldgroup="",column_name,fieldgroup)
                        
                    ) fieldgroup
                from `ds_column_form_label` 
            ) ds_column_form_label
            left join view_readtable_all_types_classic view_readtable_all_types_modern on  view_readtable_all_types_modern.type = `ds_column_form_label`.`xtype`
        where 
            `ds_column_form_label`.`active` = 1
            and `ds_column_form_label`.`hidden` = 0
        group by ds_column_form_label.table_name
    ) req on ds.table_name = req.table_name

where
    /*`ds`.`title`<>''*/ 
    true;
