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
    login varchar(255) not null
    
);

create table if not exists ds_files_data (
    file_id varchar(36) primary key not null,
    data longtext not null,
    constraint `fk_ds_files_data_file_id` foreign key (file_id) references ds_files(file_id) on delete cascade on update cascade
);