delimiter;

/*
 update ds_column_list_label set xtype='booleancolumn' where (table_name,column_name) in (
 select table_name,column_name from ds_column where   data_type='tinyint'
 ) and xtype='gridcolumn'
 
 
 if( ifnull(ds_column_list_label.editor,'')='','', concat( '"editor": "', ds_column_list_label.editor ,'"', ', ') ),
 
 
 */
alter table ds_column_list_label add if not exists width integer default 0;

create
or replace view view_ds_listcolumn as
select
    json_arrayagg(
        distinct JSON_OBJECT(
            'text',
            `ds_column_list_label`.`label`,
            'xtype',
            if(
                types.type is null,
                'gridcolumn',
                `ds_column_list_label`.`xtype`
            ),
            'dataIndex',
            concat(
                /*`ds_column`.`table_name`,'__',*/
                `ds_column`.`column_name`
            ),
            'align',
            if(
                ifnull(`ds_column_list_label`.`align`, '') <> '',
                `ds_column_list_label`.`align`,
                'start'
            ),
            'formatter',
            if(
                ifnull(`ds_column_list_label`.`renderer`, '') <> '',
                `ds_column_list_label`.`renderer`,
                ''
            ),
            'summaryType',
            if(
                ifnull(`ds_column_list_label`.`summarytype`, '') <> '',
                `ds_column_list_label`.`summarytype`,
                null
            ),
            'summaryRenderer',
            if(
                ifnull(`ds_column_list_label`.`summaryrenderer`, '') <> '',
                `ds_column_list_label`.`summaryrenderer`,
                null
            ),
            -- if(ifnull(`ds_column_list_label`.`summaryrenderer`,'')<>'',`ds_column_list_label`.`summaryrenderer`,null),
            'summaryFormatter',
            if(
                ifnull(`ds_column_list_label`.`summaryrenderer`, '') <> '',
                `ds_column_list_label`.`summaryrenderer`,
                null
            ),
            'hidden',
            if (
                `ds_column_list_label`.`hidden` = 1,
                true = true,
                false = true
            ),
            'editor',
            if(
                (ifnull(ds_column_list_label.editor, '') = ''),
                null,
                if (
                    types.type is null,
                    'missedxtypefield',
                    ds_column_list_label.editor
                )
            ),

            if(ds_column_list_label.width > 0,'width','flex') , if(ds_column_list_label.width > 0,ds_column_list_label.width,ds_column_list_label.flex),

            'filter',
            if (
                ds_column_list_label.listfiltertype <> '',
                JSON_OBJECT(
                    'type',
                    ds_column_list_label.listfiltertype
                ),
                CASE
                    ds_column.data_type
                    WHEN 'date' THEN JSON_OBJECT(
                        'type',
                        'date',
                        'dateFormat',
                        'Y-m-d',
                        'pickerDefaults', JSON_OBJECT(
                            'xtype', 'datepicker',
                            'border', 0,
                            'format',
                            'Y-m-d'
                        )
                    )
                    WHEN 'datetime' THEN JSON_OBJECT(
                        'type',
                        'date',
                        'dateFormat',
                        'Y-m-d'
                    )
                    WHEN 'number' THEN JSON_OBJECT(
                        'type',
                        'number'
                    )
                    WHEN 'boolean' THEN JSON_OBJECT(
                        'type',
                        'boolean',
                        'yesText',
                        'Ja',
                        'noText',
                        'Nein'
                    )
                    WHEN 'tinyint' THEN JSON_OBJECT(
                        'type',
                        'boolean',
                        'yesText',
                        'Ja',
                        'noText',
                        'Nein'
                    )
                    ELSE JSON_OBJECT(
                        'type',
                        'string'
                    )
                END
            )
        )
        order by
            ds_column_list_label.position
            
    ) js,
    `ds`.`table_name`,
    concat(
        '[',
        group_concat(
            distinct concat('"', types.id, '"') separator ','
        ),
        ']'
    ) `requiresJS`
from
    `ds`
    join `ds_column` on `ds`.`table_name` = `ds_column`.`table_name`
    and `ds_column`.`existsreal` = 1
    and `ds`.`title` <> ''
    join `ds_column_list_label` on (
        `ds_column`.`table_name`,
        `ds_column`.`column_name`
    ) = (
        `ds_column_list_label`.`table_name`,
        `ds_column_list_label`.`column_name`
    )
    and `ds_column_list_label`.`active` = 1
    left join view_readtable_all_types_classic types on types.type = `ds_column_list_label`.`xtype`
    and typeclass = 'widget'
group by
    `ds`.`table_name`;