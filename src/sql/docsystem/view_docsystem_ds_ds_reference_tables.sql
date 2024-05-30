DELIMITER ;
CREATE OR REPLACE VIEW  `view_docsystem_ds_ds_reference_tables` AS
select
    `ds_reference_tables`.`reference_table_name` AS `reference_table_name`,
    `ds`.`table_name` AS `table_name`,
    if(
        ifnull(`ds`.`title`, '') = '',
        'kein Titel hinterlegt',
        ifnull(`ds`.`title`, '')
    ) AS `titel`,
    if(
        ifnull(`ds`.`hint`, '') = '',
        'keine Dokumentation hinterlegt',
        ifnull(`ds`.`hint`, '')
    ) AS `hint`
from
    (
        `ds_reference_tables`
        join `ds` on(
            `ds_reference_tables`.`table_name` = `ds`.`table_name`
        )
    );