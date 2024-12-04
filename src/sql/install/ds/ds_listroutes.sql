delimiter ;

create table if not exists `ds_listroutes` (
    `table_name` varchar(128) NOT NULL,
    `route` varchar(150) NOT NULL,
    `position` integer DEFAULT 1,
    `target` varchar(10) DEFAULT '_self',
    `iconcls` varchar(100) DEFAULT 'fa-solid fa-up-right-from-square',
    PRIMARY KEY (`table_name`,`route`),
    KEY `idx_ds_listroutes_table_name` (`table_name`),
    CONSTRAINT `fk_ds_listroutes_table_name` 
        FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) 
        ON DELETE CASCADE ON UPDATE CASCADE

);

alter table `ds_listroutes` add column if not exists `target` varchar(10) DEFAULT '_self';
alter table `ds_listroutes` add column if not exists `iconcls` varchar(100) DEFAULT 'fa-solid fa-up-right-from-square';
