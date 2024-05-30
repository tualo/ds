DELIMITER ;
CREATE OR REPLACE VIEW  `view_docsystem_ds_column_documentation` AS
select
    ifnull(`docsystem_ds_column`.`id`, uuid()) AS `id`,
    `docsystem_ds_column`.`text` AS `text`,
    `ds_column`.`table_name` AS `table_name`,
    `ds_column`.`column_name` AS `column_name`,
    `ds_column_list_export`.`language` AS `export_language`,
    `ds_column_list_export`.`label` AS `export_label`,
    `ds_column_list_export`.`position` AS `export_position`,
    `ds_column_list_export`.`active` AS `export_active`,
    `ds_column_list_label`.`language` AS `list_language`,
    `ds_column_list_label`.`label` AS `list_label`,
    `ds_column_list_label`.`position` AS `list_position`,
    `ds_column_list_label`.`active` AS `list_active`,
    `ds_column_form_label`.`language` AS `form_language`,
    `ds_column_form_label`.`label` AS `form_label`,
    `ds_column_form_label`.`position` AS `form_position`,
    `ds_column_form_label`.`field_path` AS `form_field_path`,
    `ds_column_form_label`.`hidden` AS `form_hidden`,
    `ds_column_form_label`.`allowempty` AS `form_allowempty`,
    `ds_column`.`is_primary` AS `is_primary`,
    `ds_column_list_label`.`hint` AS `hint`,
    `ds_column`.`data_type` AS `data_type`,
    `ds_column`.`column_key` AS `column_key`,
    `ds_column`.`column_type` AS `column_type`,
    `ds_column`.`character_maximum_length` AS `character_maximum_length`,
    `ds_column`.`numeric_precision` AS `numeric_precision`,
    `ds_column`.`numeric_scale` AS `numeric_scale`
from
    (
        (
            (
                (
                    `ds_column`
                    left join `docsystem_ds_column` on(
                        `docsystem_ds_column`.`table_name` = `ds_column`.`table_name`
                        and `docsystem_ds_column`.`column_name` = `ds_column`.`column_name`
                    )
                )
                left join `ds_column_list_export` on(
                    `ds_column_list_export`.`table_name` = `ds_column`.`table_name`
                    and `ds_column`.`existsreal` = 1
                    and `ds_column_list_export`.`column_name` = `ds_column`.`column_name`
                )
            )
            left join `ds_column_list_label` on(
                `ds_column_list_label`.`table_name` = `ds_column`.`table_name`
                and `ds_column_list_label`.`column_name` = `ds_column`.`column_name`
            )
        )
        left join `ds_column_form_label` on(
            `ds_column_form_label`.`table_name` = `ds_column`.`table_name`
            and `ds_column_form_label`.`column_name` = `ds_column`.`column_name`
        )
    )