delimiter ;

create table if not exists ds_coloring_classes (
    id varchar(36) primary key,
    class_name varchar(128) not null,
    definition text not null
);

create table if not exists ds_coloring_formulas (
    id varchar(36) primary key,
    table_name varchar(128) not null,
    formula text not null,
    position int default 0,
    css_class text not null,
    constraint `fk_ds_coloring_formulas_ds_table` foreign key (`table_name`) references `ds` (`table_name`) on delete cascade on update cascade
);

