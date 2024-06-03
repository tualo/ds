create or replace view view_reportform_fieldgroups as
select
    `blg_config`.tabellenzusatz,
    `ds_column_form_label`.`table_name`, 
    `ds_column_form_label`.`column_name`,
    `ds_column_form_label`.`field_path`,
    `ds_column_form_label`.`fieldgroup`,
    `ds_column_form_label`.`active`,
    `ds_column_form_label`.`position`,
    count(*) c,
    if(count(*) =1,
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
                'name', `ds_column_form_label`.`column_name`,
                'bind', JSON_OBJECT( 
                    "value",concat('{',`ds_column_form_label`.`column_name`,'}')
                ),
                'listeners', JSON_OBJECT( 
                    'change', 'onFormFieldChanged'
                )
            
            )
            ,
            JSON_OBJECT(
                'fieldLabel', fieldgroup_label,
                'xtype', 'fieldcontainer',
                'layout', 'hbox',
                'flex',1,   
                'items',
                JSON_MERGE('[]', 
                    concat('[',
                    group_concat(
                        JSON_OBJECT(
                            'flex', 1,
                            'xtype',  if(view_readtable_all_types_modern.type is null,'displayfield', `ds_column_form_label`.`xtype`),
                            
                            'emptyText', `ds_column_form_label`.`label`,
                            'name', concat(`ds_column_form_label`.`column_name`),
                            'bind', JSON_OBJECT( 
                                "value",concat('{',`ds_column_form_label`.`column_name`,'}')
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
            xtype,
            field_path,
            position,
            hidden,
            flex,
            active,
            allowempty,
            fieldgroup fieldgroup_label,
            concat( 
                table_name,
                if(fieldgroup is null or fieldgroup="" or fieldgroup="1",column_name,fieldgroup)
                
            ) fieldgroup
        from `ds_column_form_label` 
    ) 
    
    ds_column_form_label
    join blg_config
        on concat('blg_hdr_',blg_config.tabellenzusatz) = ds_column_form_label.table_name

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