DELIMITER;

CREATE
OR REPLACE VIEW `view_readtable_ds_column_tagfields` AS
select
    `ds_nm_tables`.`table_name` AS `table_name`,
    ifnull(
        `ds_column_tagfields`.`column_name`,
        `ds_nm_tables`.`intermedia_table_name`
    ) AS `column_name`,
    'DE' AS `language`,
    ifnull(
        `ds_column_tagfields`.`label`,
        `ds_nm_tables`.`intermedia_table_name`
    ) AS `label`,
    concat(
        'tagfield_',
        `ds_nm_tables`.`referenced_table_name`
    ) AS `xtype`,
    ifnull(`ds_column_tagfields`.`field_path`, 'Allgemein') AS `field_path`,
    ifnull(`ds_column_tagfields`.`position`, 99) AS `position`,
    ifnull(`ds_column_tagfields`.`hidden`, 1) AS `hidden`,
    ifnull(`ds_column_tagfields`.`active`, 0) AS `active`,
    ifnull(
        `ds_column_tagfields`.`referenced_table_name`,
        `ds_nm_tables`.`referenced_table_name`
    ) AS `referenced_table_name`,
    ifnull(
        `ds_column_tagfields`.`constraint_name`,
        `ds_nm_tables`.`constraint_name`
    ) AS `constraint_name`,
    ifnull(
        `ds_column_tagfields`.`referenced_constraint_name`,
        `ds_nm_tables`.`referenced_constraint_name`
    ) AS `referenced_constraint_name`,
    ifnull(
        `ds_column_tagfields`.`table_name_json`,
        `ds_nm_tables`.`table_name_json`
    ) AS `table_name_json`,
    ifnull(
        `ds_column_tagfields`.`referenced_table_json`,
        `ds_nm_tables`.`referenced_table_json`
    ) AS `referenced_table_json`
from
    (
        `ds_nm_tables`
        left join `ds_column_tagfields` on(
            `ds_nm_tables`.`table_name` = `ds_column_tagfields`.`table_name`
            and `ds_nm_tables`.`intermedia_table_name` = `ds_column_tagfields`.`column_name`
        )
    );