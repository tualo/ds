delimiter ;

create table if not exists ds_files (
    file_id varchar(36) primary key default uuid(),
    
    name varchar(255) not null,
    path varchar(255) not null,

    size integer not null,
    mtime datetime not null,
    ctime datetime not null,

    type varchar(255) not null,
    hash varchar(36) not null,
    login varchar(255) not null,
    table_name varchar(128) not null,
    key `idx_ds_files_table_name` (table_name),
    key `idx_ds_files_hash` (hash),
    key `idx_ds_files_login` (login)
);


create table if not exists ds_files_data (
    file_id varchar(36) primary key not null,
    data longtext not null,
    constraint `fk_ds_files_data_file_id` foreign key (file_id) references ds_files(file_id) on delete cascade on update cascade
);


CREATE TABLE IF NOT EXISTS `ds_files_data_chunks` (
  `file_id` varchar(36) NOT NULL,
  `page` integer default 0,
  `data` longtext NOT NULL,
  PRIMARY KEY (`file_id`,`page`),
  CONSTRAINT `fk_ds_files_data_chunks_file_id` FOREIGN KEY (`file_id`) REFERENCES `ds_files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ;


delimiter //

 
CREATE OR REPLACE PROCEDURE `ds_files_cleanup`( IN  in_table_name varchar(128))
BEGIN 
    declare sql_command longtext;
    declare _sql_temporary_table longtext;

    drop table if exists cleanup_ds_files_tmp;
    SET _sql_temporary_table = CONCAT('create temporary table if not exists  cleanup_ds_files_tmp as 
        select file_id from ds_files where table_name=',quote(in_table_name),' and  file_id not in (select file_id from `',in_table_name,'`)
    ');
    PREPARE _sql FROM _sql_temporary_table;
    EXECUTE _sql;
    DEALLOCATE PREPARE _sql;

    for rec in ( select * from cleanup_ds_files_tmp  ) do
        -- start transaction;
        delete from ds_files where file_id = rec.file_id;
        -- commit;
    end for;

    /*
    set sql_command = concat('delete from ds_files where table_name=',quote(in_table_name),' and  file_id not in (select file_id from `',in_table_name,'`) limit 10');
    PREPARE stmt FROM sql_command;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    */
END //