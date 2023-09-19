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

delimiter //

CREATE OR REPLACE PROCEDURE `ds_files_cleanup`( IN  in_table_name varchar(128))
BEGIN 
    declare sql_command longtext;
    set sql_command = concat('delete from ds_files where table_name=',quote(in_table_name),' and  file_id not in (select file_id from `',in_table_name,'`) ');
    PREPARE stmt FROM sql_command;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //