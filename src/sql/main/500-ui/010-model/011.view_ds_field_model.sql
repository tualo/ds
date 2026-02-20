delimiter ;

CREATE OR REPLACE VIEW `view_ds_field_model` AS
with name as (
    select
        concat(
            lcase(`ds_dropdownfields`.`table_name`),
            '.',
            ucase(left(`ds_dropdownfields`.`name`, 1)),
            lcase(substr(`ds_dropdownfields`.`name`, 2))
        ) append_name,
        concat(
            'Tualo.DataSets.model.',
            lcase(`ds_dropdownfields`.`table_name`),
            '.',
            ucase(left(`ds_dropdownfields`.`name`, 1)),
            lcase(substr(`ds_dropdownfields`.`name`, 2))
        ) AS `name`,
        concat(
            'Tualo/DataSets/model/',
            lcase(`ds_dropdownfields`.`table_name`),
            '/',
            ucase(left(`ds_dropdownfields`.`name`, 1)),
            lcase(substr(`ds_dropdownfields`.`name`, 2))
        ) AS `filename`,
        
        table_name,
        idfield,
        name shortname,
        displayfield
    from 
        ds_dropdownfields
),
definition as (
select 
name,
filename,
append_name,
name.shortname,
name.displayfield,
name.idfield,
json_object(
    'extend', `ds`.`modelbaseclass`,
    'entityName', concat(`ds`.`table_name`,'_',name.shortname),
    'idProperty', name.idfield,
    'clientIdProperty', name.idfield,
    'fields',
    json_array(
        json_object(
            "name",name.idfield,
             "critical", 1=1,
            'type',
            if(
                `ds_column_idfield`.`fieldtype` <> '',
                `ds_column_idfield`.`fieldtype`,
                if(
                    `ds_column_idfield`.`column_type` = 'bigint(4)'
                    or `ds_column_idfield`.`column_type` = 'int(4)'
                    or `ds_column_idfield`.`column_type` = 'tinyint(4)',
                    'boolean',
                    ifnull(
                        `ds_column_forcetype_idfield`.`fieldtype`,
                        ifnull(`ds_db_types_fieldtype_idfield`.`fieldtype`, 'string')
                    )
                )
            )
        ),

        json_object(
            "name",name.displayfield, 
            "critical", 1=1,
            'type',
            if(
                `ds_column_displayfield`.`fieldtype` <> '',
                `ds_column_displayfield`.`fieldtype`,
                if(
                    `ds_column_displayfield`.`column_type` = 'bigint(4)'
                    or `ds_column_displayfield`.`column_type` = 'int(4)'
                    or `ds_column_displayfield`.`column_type` = 'tinyint(4)',
                    'boolean',
                    ifnull(
                        `ds_column_forcetype_displayfield`.`fieldtype`,
                        ifnull(`ds_db_types_fieldtype_displayfield`.`fieldtype`, 'string')
                    )
                )
            )
        )
    ) 
    ) object,
    ds.table_name

from name
    join ds on name.table_name=ds.table_name
    join ds_column as ds_column_idfield on
        ds_column_idfield.column_name = name.idfield
        and ds_column_idfield.table_name = name.table_name
    join ds_column as ds_column_displayfield on
        ds_column_displayfield.column_name = name.displayfield
        and ds_column_displayfield.table_name = name.table_name

    
    left join `ds_column_forcetype` ds_column_forcetype_idfield on(
            (
                `ds_column_idfield`.`table_name`,
                `ds_column_idfield`.`column_name`
            ) = (
                `ds_column_forcetype_idfield`.`table_name`,
                `ds_column_forcetype_idfield`.`column_name`
            )
        )
    left join `ds_column_forcetype` ds_column_forcetype_displayfield on(
            (
                `ds_column_idfield`.`table_name`,
                `ds_column_idfield`.`column_name`
            ) = (
                `ds_column_forcetype_displayfield`.`table_name`,
                `ds_column_forcetype_displayfield`.`column_name`
            )
        )
    left join `ds_db_types_fieldtype` ds_db_types_fieldtype_idfield on(
                `ds_column_idfield`.`data_type` = `ds_db_types_fieldtype_idfield`.`dbtype`
            )
    left join `ds_db_types_fieldtype` ds_db_types_fieldtype_displayfield on(
                `ds_column_displayfield`.`data_type` = `ds_db_types_fieldtype_displayfield`.`dbtype`
            )
) 
select 
    append_name,
    name,
    concat(filename,'.js') filename,
    shortname,
    displayfield,
    idfield,
    concat(
        'Ext.define(',quote(name),',',object,')'
    ) AS `js`,
    `table_name` AS `table_name`
from 
    definition

;