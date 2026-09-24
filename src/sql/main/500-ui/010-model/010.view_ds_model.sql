delimiter;

CREATE TABLE IF NOT EXISTS `ds_additional_columns` (
  `table_name` varchar(128) NOT NULL,
  `column_name` varchar(64) NOT NULL,
  `sql_command` text DEFAULT NULL,
  `checked` tinyint(4) DEFAULT 0,
  `error_message` varchar(255) DEFAULT '',
  PRIMARY KEY (`table_name`,`column_name`),
  CONSTRAINT `fk_ds_additional_columns_ds` FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `ds_virtual_columns` (
  `table_name` varchar(128) NOT NULL,
  `column_name` varchar(64) NOT NULL,
  `checked` tinyint(4) DEFAULT 0,
  `type` varchar(128) NOT NULL,
  PRIMARY KEY (`table_name`,`column_name`),
  CONSTRAINT `fk_ds_virtual_columns_ds` FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ;

call addfieldifnotexists(
    'ds',
    'modelbaseclass',
    'varchar(100) default "Tualo.DataSets.model.Basic"'
);

-- Create or replace view for ds_column including virtual columns
create
or replace view view_ds_model_ds_column as
select
    table_name,
    column_name,
    default_value,
    default_max_value,
    default_min_value,
    update_value,
    is_primary,
    syncable,
    referenced_table,
    referenced_column_name,
    is_nullable,
    is_referenced,
    writeable,
    note,
    data_type,
    column_key,
    column_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    character_set_name,
    privileges,
    existsreal,
    deferedload,
    hint,
    fieldtype,
    is_generated
from
    ds_column
union
select
    ds_virtual_columns.table_name,
    ds_virtual_columns.column_name,
    '' default_value,
    '' default_max_value,
    '' default_min_value,
    '' update_value,
    0 is_primary,
    0 syncable,
    null referenced_table,
    null referenced_column_name,
    0 is_nullable,
    0 is_referenced,
    0 writeable,
    '' note,
    'varchar' data_type,
    '' column_key,
    'varchar(255)' column_type,
    1 character_maximum_length,
    0 numeric_precision,
    0 numeric_scale,
    '' character_set_name,
    '' privileges,
    ds_virtual_columns.checked existsreal,
    0 deferedload,
    '' hint,
    type fieldtype,
    1 is_generated
from
    ds_virtual_columns;

create
or replace view view_ds_column_merge as
select
    `ds_column`.`table_name`,
    `ds_column`.`column_name`,
    if (
        ds_column.column_type in ('date', 'datetime', 'time', 'timestamp'),
        JSON_OBJECT(
            "dateFormat",
            if (
                ds_column.column_type = 'date',
                "Y-m-d",
                if (
                    ds_column.column_type = 'datetime',
                    "Y-m-d H:i:s",
                    if (
                        ds_column.column_type = 'time',
                        "H:i:s",
                        if (
                            ds_column.column_type = 'timestamp',
                            "Y-m-d H:i:s",
                            ""
                        )
                    )
                )
            ),
            "dateWriteFormat",
            if (
                ds_column.column_type = 'date',
                "Y-m-d",
                if (
                    ds_column.column_type = 'datetime',
                    "Y-m-d H:i:s",
                    if (
                        ds_column.column_type = 'time',
                        "H:i:s",
                        if (
                            ds_column.column_type = 'timestamp',
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
        JSON_OBJECT() --        )
    ) obj
from
    view_ds_model_ds_column ds_column
where
    ds_column.existsreal = 1 -- ds_column.data_type in ('date','datetime','time')
;

call addfieldifnotexists(
    'ds_column',
    'fieldtype',
    'varchar(100) default ""'
);

CREATE
OR REPLACE VIEW `view_ds_model` AS with prepared_data as (
    select
        view_readtable_all_types.id,
        `ds`.`modelbaseclass`,
        `ds`.`table_name`,
        `ds_column`.`column_name`,
        `ds_column`.`fieldtype`,
        ds_column.is_nullable,
        ds_column.column_type,
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
        ) type,
        `ds_column`.`default_value`,
        `ds_column`.`is_primary`,
        `ds`.`use_insert_for_update`,
        ifnull(`view_ds_column_merge`.`obj`, '{}') obj
    from
        (
            (
                (
                    (
                        `ds`
                        join view_ds_model_ds_column `ds_column` on(
                            `ds`.`table_name` = `ds_column`.`table_name`
                            and `ds_column`.`existsreal` = 1
                        )
                        join `view_readtable_all_types` on view_readtable_all_types.xtype_long_classic = concat(
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
                    left join `view_ds_column_merge` on(
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
)
select
    concat(
        'Tualo.DataSets.model.',
        ucase(left(`prepared_data`.`table_name`, 1)),
        lcase(substr(`prepared_data`.`table_name`, 2))
    ) AS `name`,
    concat(
        'Tualo/DataSets/model/',
        ucase(left(`prepared_data`.`table_name`, 1)),
        lcase(substr(`prepared_data`.`table_name`, 2)),
        '.js'
    ) AS `filename`,
    concat(
        'Ext.define(',
        quote(
            concat(
                'Tualo.DataSets.model.',
                ucase(left(`prepared_data`.`table_name`, 1)),
                lcase(substr(`prepared_data`.`table_name`, 2))
            )
        ),
        ', ',
        json_object(
            'extend',
            `prepared_data`.`modelbaseclass`,
            'entityName',
            `prepared_data`.`table_name`,
            'idProperty',
            '__id',
            'requires',
            json_arrayagg(
                distinct prepared_data.id
            ),
            'clientIdProperty',
            '__clientid',
            'fields',
            json_merge_preserve(
                concat(
                    '[',
                    '{"name": "__table_name", "defaultValue": "',
                    `prepared_data`.`table_name`,
                    '","critical": true,"type":"string"},',
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
                                    concat(`prepared_data`.`column_name`),
                                    'allowNull',
                                    if(
                                        `prepared_data`.`is_nullable` = 'YES',
                                        true,
                                        if(
                                            `prepared_data`.`default_value` <> '',
                                            true,
                                            false
                                        )
                                    ),
                                    'type', `prepared_data`.`type`
                                ),
                                if(
                                    (
                                        ifnull(`prepared_data`.`default_value`, '') = ''
                                    )
                                    or (
                                        (
                                            substr(`prepared_data`.`default_value`, 1, 1) = '{'
                                        )
                                        and (`prepared_data`.`default_value` <> '{#serial}')
                                    ),
                                    '{}',
                                    json_object(
                                        'defaultValue',
                                        if (
                                            (`prepared_data`.`default_value` <> '{#serial}'),
                                            `prepared_data`.`default_value`,
                                            null
                                        )
                                    )
                                ),
                                -- if ( ( `ds_column`.`default_value` = '{#serial}'), json_object( 'allowNull', true), '{}'),
                                if(
                                    `prepared_data`.`is_primary` = 1
                                    or `prepared_data`.`use_insert_for_update` = 1,
                                    '{"critical": true}',
                                    '{}'
                                ),
                                `prepared_data`.`obj`
                            )
                            order by
                                `prepared_data`.`column_name` ASC separator ','
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
    `prepared_data`.`table_name` AS `table_name`
from
    prepared_data
group by
    `prepared_data`.`table_name`;