DELIMITER;

CREATE
OR REPLACE VIEW `view_readtable_ds_used_tables` AS
select
    `ds_used_tables`.`table_name` AS `table_name`,
    `ds_used_tables`.`used_table_name` AS `used_table_name`
from
    `ds_used_tables`
union
select
    `ds`.`table_name` AS `table_name`,
    `ds`.`table_name` AS `used_table_name`
from
    `ds`;