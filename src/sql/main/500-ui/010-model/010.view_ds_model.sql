delimiter ;

call addfieldifnotexists('ds','modelbaseclass','varchar(100) default "Tualo.DataSets.model.Basic"');


create or replace view view_ds_column_merge as
select
    `ds_column`.`table_name`, 
    `ds_column`.`column_name`,
    if ( ds_column.column_type in ('date','datetime','time','timestamp'),
        JSON_OBJECT(
            "dateFormat", 
            if (
                ds_column.column_type ='date',
                "Y-m-d",
                if (
                    ds_column.column_type ='datetime',
                    "Y-m-d H:i:s",
                    if (
                        ds_column.column_type ='time',
                        "H:i:s",
                        if (
                            ds_column.column_type ='timestamp',
                            "Y-m-d H:i:s",
                            ""
                        )
                    )
                )
            ),
            "dateWriteFormat", 
            if (
                ds_column.column_type ='date',
                "Y-m-d",
                if (
                    ds_column.column_type ='datetime',
                    "Y-m-d H:i:s",
                    if (
                        ds_column.column_type ='time',
                        "H:i:s",
                        if (
                            ds_column.column_type ='timestamp',
                            "Y-m-d H:i:s",
                            ""
                        )
                    )
                )
            )
        ),
--        if (ds_column.data_type in ('varchar'),
--            JSON_OBJECT(
--                "maxLength", ds_column.character_maximum_length
--            ),
            JSON_OBJECT()
--        )
    )
     obj
from 
    ds_column
where ds_column.existsreal = 1
    -- ds_column.data_type in ('date','datetime','time')
;


call addfieldifnotexists('ds_column','fieldtype','varchar(100) default ""');
CREATE
OR REPLACE VIEW `view_ds_model` AS
select
    concat(
        'Tualo.DataSets.model.',
        ucase(left(`ds`.`table_name`, 1)),
        lcase(substr(`ds`.`table_name`, 2))
    ) AS `name`,
    concat(
        'Tualo/DataSets/model/',
        ucase(left(`ds`.`table_name`, 1)),
        lcase(substr(`ds`.`table_name`, 2)),
        '.js'
    ) AS `filename`,
    concat(
        'Ext.define(',
        quote(
            concat(
                'Tualo.DataSets.model.',
                ucase(left(`ds`.`table_name`, 1)),
                lcase(substr(`ds`.`table_name`, 2))
            )
        ),
        ', ',
        json_object(
            'extend', `ds`.`modelbaseclass`,
            'entityName', `ds`.`table_name`,
            'idProperty', '__id',
            'requires', json_arrayagg(
                distinct
                view_readtable_all_types.id
            ),
            'clientIdProperty', '__clientid',
            'fields',
            json_merge_preserve(
                concat(
                    '[',
                        '{"name": "__table_name", "defaultValue": "', `ds`.`table_name`, '","critical": true,"type":"string"},',
                        '{"name": "__id", "critical": true, "type":"string"},',
                        '{"name": "__rownumber", "critical": true, "type":"number"}',
                    ']'
                ),
                ifnull(
                    concat(
                        '[',
                        group_concat(
                            json_merge_preserve(
                                json_object(
                                    'name',
                                    concat(`ds_column`.`column_name`),
                                    'type',
                                    if(
                                        `ds_column`.`fieldtype` <> '',
                                        `ds_column`.`fieldtype`,
                                        if(
                                            `ds_column`.`column_type` = 'bigint(4)'
                                            or `ds_column`.`column_type` = 'int(4)'
                                            or `ds_column`.`column_type` = 'tinyint(4)',
                                            'boolean',
                                            ifnull(
                                                `ds_column_forcetype`.`fieldtype`,
                                                ifnull(`ds_db_types_fieldtype`.`fieldtype`, 'string')
                                            )
                                        )
                                    )
                                ),
                                if(
                                    (ifnull( `ds_column`.`default_value`,'' ) = '') or 
                                    (
                                        ( substr(`ds_column`.`default_value`, 1, 1) = '{')
                                        and 
                                        ( `ds_column`.`default_value` <> '{#serial}')
                                    )
                                    ,
                                    '{}',
                                    json_object(
                                        'defaultValue',
                                        if (
                                             ( `ds_column`.`default_value` <> '{#serial}'),
                                                `ds_column`.`default_value`,
                                                -1
                                        )
                                        
                                    )
                                ),
                                if(
                                    `ds_column`.`is_primary` = 1,
                                    '{"critical": true}',
                                    '{}'
                                ),
                                `view_ds_column_merge`.`obj`
                            )
                            order by
                                `ds_column`.`column_name` ASC separator ','
                        ),
                        ']'
                    ),
                    '[]'
                )
            )
        ),
        ')',
        char(59)
    ) AS `js`,
    `ds`.`table_name` AS `table_name`
from
    (
        (
            (
                (
                    `ds`
                    join `ds_column` on(
                        `ds`.`table_name` = `ds_column`.`table_name`
                        and `ds_column`.`existsreal` = 1
                    )
                    join `view_readtable_all_types`
                    on  view_readtable_all_types.xtype_long_classic  = concat( 
                        'data.field.',
                        if(
                            `ds_column`.`fieldtype` <> '',
                            `ds_column`.`fieldtype`,
                            if(
                                `ds_column`.`column_type` = 'bigint(4)'
                                or `ds_column`.`column_type` = 'int(4)'
                                or `ds_column`.`column_type` = 'tinyint(4)',
                                'boolean',
                                'string'
                            )
                        )
                    )
                )
                join `view_ds_column_merge` on(
                    `view_ds_column_merge`.`table_name` = `ds_column`.`table_name`
                    and `view_ds_column_merge`.`column_name` = `ds_column`.`column_name`
                )
            )
            left join `ds_db_types_fieldtype` on(
                `ds_column`.`data_type` = `ds_db_types_fieldtype`.`dbtype`
            )
        )
        left join `ds_column_forcetype` on(
            (
                `ds_column`.`table_name`,
                `ds_column`.`column_name`
            ) = (
                `ds_column_forcetype`.`table_name`,
                `ds_column_forcetype`.`column_name`
            )
        )
    )
group by
    `ds`.`table_name`;