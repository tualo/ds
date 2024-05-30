DELIMITER ;
CREATE OR REPLACE VIEW `view_docsystem_ds_access` AS with dsa as (
    select
        md5(
            concat(
                `ds`.`table_name`,
                '',
                `ds_access`.`read`,
                '',
                `ds_access`.`write`,
                '',
                `ds_access`.`delete`,
                '',
                `ds_access`.`append`
            )
        ) AS `signature`,
        `ds`.`table_name` AS `table_name`,
        `ds`.`title` AS `title`,
        `ds`.`class_name` AS `class_name`,
        `ds_access`.`role` AS `role`,
        `ds_access`.`read` AS `read`,
        `ds_access`.`write` AS `write`,
        `ds_access`.`delete` AS `delete`,
        `ds_access`.`append` AS `append`,
        ifnull(`ds_access`.`read`, 0) + ifnull(`ds_access`.`write`, 0) + ifnull(`ds_access`.`delete`, 0) + ifnull(`ds_access`.`append`, 0) AS `has_any`
    from
        (
            `ds_access`
            join `ds` on(
                `ds`.`table_name` = `ds_access`.`table_name`
                and `ds`.`existsreal` = 1
                and `ds`.`title` <> ''
            )
        )
)
select
    `dsa`.`signature` AS `signature`,
    `dsa`.`table_name` AS `table_name`,
    `dsa`.`title` AS `title`,
    `dsa`.`class_name` AS `class_name`,
    `dsa`.`role` AS `role`,
    `dsa`.`read` AS `read`,
    `dsa`.`write` AS `write`,
    `dsa`.`delete` AS `delete`,
    `dsa`.`append` AS `append`,
    `dsa`.`has_any` AS `has_any`,
    ifnull(
        group_concat(
            distinct `x`.`role`
            order by
                `x`.`role` ASC separator ', '
        ),
        ''
    ) AS `same_rights`
from
    (
        `dsa`
        left join `dsa` `x` on(
            `dsa`.`signature` = `x`.`signature`
            and `dsa`.`role` <> `x`.`role`
        )
    )
group by
    `dsa`.`table_name`,
    `dsa`.`role`;