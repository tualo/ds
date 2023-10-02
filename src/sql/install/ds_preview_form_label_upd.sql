delimiter;

call addFieldIfNotExists(
    "ds_preview_form_label",
    "dockposition",
    "varchar(20) DEFAULT 'left'"
);

CREATE OR REPLACE VIEW `view_readtable_ds_preview_form_label_all` AS
select
    ifnull(`tc`.`table_name`, `ic`.`table_name`) AS `table_name`,
    ifnull(`tc`.`column_name`, `ic`.`column_name`) AS `column_name`,
    ifnull(`tc`.`language`, 'DE') AS `language`,
    ifnull(`tc`.`label`, `ic`.`column_name`) AS `label`,
    ifnull(`tc`.`xtype`, 'displayfield') AS `xtype`,
    ifnull(`tc`.`field_path`, '') AS `editor`,
    ifnull(`tc`.`position`, 999) AS `position`,
    ifnull(`tc`.`active`, 0) AS `active`,
    ifnull(`tc`.`dockposition`, 'left') AS `dockposition`
from
    (
        `ds_column` `ic`
        left join `ds_preview_form_label` `tc` on(
            `tc`.`table_name` = `ic`.`table_name`
            and `tc`.`column_name` = `ic`.`column_name`
        )
    );