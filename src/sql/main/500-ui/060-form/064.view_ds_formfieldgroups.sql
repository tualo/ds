delimiter ;


call addfieldifnotexists('ds_column_form_label','fieldgroup','varchar(50) default ""');
call addfieldifnotexists('ds_column_form_label','flex','decimal(5,2) default 1');
call addfieldifnotexists('ds_reference_tables','tabtitle','varchar(50) default ""');




create or replace view view_ds_formfield_merge as
select
    `ds_column`.`table_name`, 
    `ds_column`.`column_name` -- ,
--    if (
        --ds_column.data_type in ('varchar')
        --and ds_column_form_label.xtype not like 'combobox_%'
        --and ds_column_form_label.xtype not like 'tualo_projectmanagement_translators%',
        --JSON_OBJECT(
        --    "maxLength", ds_column.character_maximum_length
        --),

--        JSON_OBJECT()
--    ) obj
from 
    ds_column
    join ds_column_form_label on (ds_column.table_name,ds_column.column_name) = (ds_column_form_label.table_name,ds_column_form_label.column_name)
where ds_column.existsreal = 1
    -- ds_column.data_type in ('date','datetime','time')
;


create or replace view view_ds_formfieldgroups as
select
    `ds_column_form_label`.`table_name`, 
    `ds_column_form_label`.`column_name`,
    `ds_column_form_label`.`field_path`,
    `ds_column_form_label`.`fieldgroup`,
    `ds_column_form_label`.`active`,
    `ds_column_form_label`.`position`,
    count(*) c,
    if(
        count(*) =1,
        
        JSON_OBJECT(

            'fieldLabel', `ds_column_form_label`.`label`,
            -- 'boxLabel', `ds_column_form_label`.`label`,
            'flex', `ds_column_form_label`.flex,
            'tablename', `ds_column_form_label`.`table_name`,
            'xtype',  
                if(view_readtable_all_types_modern.type is null,
                    'missedxtypefield', `ds_column_form_label`.`xtype`
            ),

            'missedXtype', if(view_readtable_all_types_modern.type is null,`ds_column_form_label`.`xtype`,''),
            

            'placeholder', `ds_column_form_label`.`label`,
            'name', concat( /*`ds_column_form_label`.`table_name`,'__',*/`ds_column_form_label`.`column_name`),
            'bind', JSON_OBJECT( 
                "value",concat('{record.',/*`ds_column_form_label`.`table_name`,'__',*/`ds_column_form_label`.`column_name`,'}')
            ),
            'listeners', JSON_OBJECT( 
                'change', 'onFormFieldChanged'
            )
        
        )
        ,
        JSON_OBJECT(
            'fieldLabel', group_concat( `ds_column_form_label`.`label` ORDER BY `ds_column_form_label`.`position` separator ' | '),
            'xtype', 'fieldcontainer',
            'layout', 'hbox',
            'flex',1,   
            'items',
            JSON_MERGE('[]', 
                concat('[',
                group_concat(
                    
                    JSON_OBJECT(
    
                        -- 'label', `ds_column_form_label`.`label`,
                        'flex', 1,
                        'xtype',  if(view_readtable_all_types_modern.type is null,'displayfield', `ds_column_form_label`.`xtype`),
                        
                        -- 'triggers', JSON_OBJECT(
                        --     "clear", JSON_OBJECT( "type", 'clear')/*,
                        --     "undo", JSON_OBJECT( "type", 'trigger', "iconCls", 'x-fa fa-undo',"weight",-2000) 
                        -- ),

                        'emptyText', `ds_column_form_label`.`label`,
                        'name', concat( /*`ds_column_form_label`.`table_name`,'__',*/ `ds_column_form_label`.`column_name`),
                        'bind', JSON_OBJECT( 
                            "value",concat('{record.',/*`ds_column_form_label`.`table_name`,'__',*/ `ds_column_form_label`.`column_name`,'}')
                        ),

         

                        'listeners', JSON_OBJECT( 
                            'change', 'onFormFieldChanged'
                        )
                        
                    )
                    
                    ORDER BY `ds_column_form_label`.`position`
                    separator ','
                ),
                ']'
                )
            )
        )
    
    ) jsfield

from 
    (
        select 
            table_name,
            column_name,
            language,
            label,
            ifnull(xtype,'displayfield') xtype,
            field_path,
            position,
            hidden,
            flex,
            active,
            allowempty,
            concat( 
                table_name,
                if(fieldgroup is null or fieldgroup="" or fieldgroup="1",column_name,fieldgroup)
                
            ) fieldgroup
        from `ds_column_form_label` 
    ) 
    
    ds_column_form_label
    
    /*join view_ds_formfield_merge
        on view_ds_formfield_merge.table_name = `ds_column_form_label`.`table_name`
        and view_ds_formfield_merge.column_name = `ds_column_form_label`.`column_name`
    */

    left join view_readtable_all_types_classic view_readtable_all_types_modern
         on  view_readtable_all_types_modern.type = `ds_column_form_label`.`xtype`
         and typeclass='widget'
where 
    `ds_column_form_label`.`active` = 1
    and `ds_column_form_label`.`hidden` = 0
--    and `ds_column_form_label`.`table_name` = 'adressen'
--    and  field_path='Allgemein/Anschrift'
group by 

    `ds_column_form_label`.`table_name`, 
    `ds_column_form_label`.`field_path`,
    `ds_column_form_label`.`fieldgroup` 
;