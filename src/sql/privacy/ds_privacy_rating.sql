DELIMITER;

CREATE TABLE IF NOT EXISTS `ds_privacy_rating` (
    `table_name` varchar(128) NOT NULL,
    `type_id` varchar(36) NOT NULL,
    `active` tinyint(4) DEFAULT 0,
    PRIMARY KEY (`table_name`, `type_id`),
    KEY `fk_ds_privacy_rating_type_id` (`type_id`),
    CONSTRAINT `fk_ds_privacy_rating_table_name` FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_ds_privacy_rating_type_id` FOREIGN KEY (`type_id`) REFERENCES `ds_privacy_rating_types` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE
OR REPLACE VIEW `view_readtable_ds_privacy_rating` AS
select
    `ds`.`table_name` AS `table_name`,
    `ds_privacy_rating_types`.`id` AS `type_id`,
    ifnull(`ds_privacy_rating`.`active`, 0) AS `active`
from
    (
        (
            `ds`
            join `ds_privacy_rating_types`
        )
        left join `ds_privacy_rating` on(
            `ds`.`table_name` = `ds_privacy_rating`.`table_name`
            and `ds_privacy_rating_types`.`id` = `ds_privacy_rating`.`type_id`
        )
    );