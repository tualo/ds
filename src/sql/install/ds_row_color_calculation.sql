delimiter ;

create table if not exists ds_row_color_calculation (
    table_name varchar(128) not null,
    column_name varchar(64) not null,
    color_calculation text not null,
    primary key (table_name,column_name),
    constraint fk_ds_row_color_calculation_ds foreign key (table_name) references ds (table_name) on delete cascade on update cascade
);