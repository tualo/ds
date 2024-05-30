DELIMITER ;

CREATE TABLE IF NOT EXISTS `docsystem_groups` (
    `group` varchar(100) NOT NULL,
    `text` longtext DEFAULT NULL,
    PRIMARY KEY (`group`)
);

CREATE OR REPLACE VIEW `view_readtable_docsystem_groups` AS
select
    `view_session_groups`.`group` AS `group`,
    `docsystem_groups`.`text` AS `text`
from
    (
        `view_session_groups`
        left join `docsystem_groups` on(
            `view_session_groups`.`group` = `docsystem_groups`.`group`
        )
    );