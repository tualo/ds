
create table if not exists log_table (
    `id` varchar(36) primary key,
    `session_token` varchar(36),
    `statement` longtext,
    `login` varchar(255),
    `created_at` timestamp default current_timestamp
) //
CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_log_statemant`( IN  stmt longtext )
BEGIN 
    INSERT INTO log_table (`id`, `session_token`, `statement`, `login`) VALUES (uuid(), @logger_session_token, stmt, getSessionUser());
END 