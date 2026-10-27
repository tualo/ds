delimiter //

create table if not exists log_table (
    `id` varchar(36) primary key,
    `session_token` varchar(36),
    `statement` longtext,
    `login` varchar(255),
    `created_at` timestamp default current_timestamp
) //

create table if not exists dsx_logger_config (
    `id` int primary key,
    `use_logger` tinyint(1) default 0
) //

insert ignore into dsx_logger_config (`id`, `use_logger`) values (1, 0) //
drop procedure if exists `dsx_rest_api_set_log_statemant` // 

CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_log_statement`( IN  stmt longtext )
BEGIN 
    if exists(select `use_logger` from dsx_logger_config where `id` = 1 and `use_logger` = 1) then
        INSERT INTO log_table (`id`, `session_token`, `statement`, `login`) VALUES (uuid(), @logger_session_token, stmt, getSessionUser());
    end if;
END //