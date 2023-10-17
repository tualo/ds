delimiter ;

create table if not exists ds_property_types (
    type varchar(10) not null primary key
);
insert ignore into ds_property_types (type) values ('date');
insert ignore into ds_property_types (type) values ('number');
insert ignore into ds_property_types (type) values ('boolean');
insert ignore into ds_property_types (type) values ('string');

create table if not exists ds_property_definition (
    table_name varchar(128) not null,
    property varchar(50) not NULL,
    primary key (table_name, property),
    type varchar(10) not null,
    constraint fk_ds_property_definition_ds foreign key (table_name) references ds (table_name) 
    on delete cascade on update cascade,
    constraint fk_ds_property_definition_ds_property_types foreign key (type) references ds_property_types (type)
    on delete cascade on update cascade
);

DELIMITER //
CREATE OR REPLACE PROCEDURE `create_or_refresh_ds_properties`( in use_table_name varchar(128) )
    MODIFIES SQL DATA
BEGIN

select 
        ifnull(concat(' ',group_concat(concat( FIELDQUOTE(ds_column.column_name),' ',ds_column.column_type) order by column_name separator ','),' '),'null'),
        ifnull(concat(' ',group_concat(concat( FIELDQUOTE(ds_column.column_name),' ') order by column_name separator ','),' '),'null'),
        ifnull(concat(' ',group_concat(concat( 'p.',FIELDQUOTE(ds_column.column_name),' ') order by column_name separator ','),' '),'null'),
        ifnull(concat(' ',group_concat(concat( 'u.',FIELDQUOTE(ds_column.column_name),' ') order by column_name separator ','),' '),'null')
    into 
        @keys_def,
        @keys,
        @p_keys,
        @u_keys
    from 
        ds_column
    where 
        ds_column.table_name = use_table_name
        and ds_column.existsreal = 1
        and ds_column.is_primary = 1
        and ds_column.column_key like '%PRI%'
    ;

SET @SQL=concat('
create table if not exists ',use_table_name,'_properties (
    ',@keys_def,',
    property_name varchar(50) not null,
    CONSTRAINT `fk_',use_table_name,'_properties` FOREIGN KEY (',@keys,') REFERENCES `',use_table_name,'` (',@keys,') 
    ON DELETE CASCADE ON UPDATE CASCADE,
    
    property_type varchar(10) not null,
    constraint fk_',use_table_name,'_properties_ds_property_types foreign key (property_type) references ds_property_types (type)
    on delete cascade on update cascade,


    date_value date not null default curdate(),
    number_value decimal(15,6) not null default 0,
    boolean_value tinyint not null default 0,
    string_value longtext not null default \'\',

    
    primary key (',@keys,',`property_name`)
)
');
        PREPARE stmt FROM @SQL;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

SET @SQL=concat('
create or replace view view_readtable_',use_table_name,'_properties as 
select
    ',@u_keys,',
    ds_property_definition.property property_name,
    ds_property_definition.property `source`,
    if (
        ds_property_definition.type="date",
        p.date_value,
        if (
            ds_property_definition.type="number",
            p.number_value,
            if (
                ds_property_definition.type="boolean",
                p.boolean_value,
                p.string_value
            )
        )
    ) value,
    ds_property_definition.type `type`,
    p.date_value as date_value,
    p.number_value as number_value,
    p.boolean_value as boolean_value,
    p.string_value as string_value
from 
    ds_property_definition
    join ',use_table_name,' u
    left join 
    ',use_table_name,'_properties p
    on
        ds_property_definition.table_name="',use_table_name,'"
        and ds_property_definition.property=p.property_name
        and (',@p_keys,') = (',@u_keys,')
;
');
        PREPARE stmt FROM @SQL;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

call fill_ds(concat('',use_table_name,'_properties'));
update ds set read_table=concat('view_readtable_',use_table_name,'_properties'), listviewbaseclass='Ext.grid.property.Grid'
where table_name=concat('',use_table_name,'_properties');

call fill_ds(concat('',use_table_name,'_properties'));
update ds_column set 
fieldtype = 'tualo_ds_property_value' where table_name=concat('',use_table_name,'_properties')
and column_name in ('date_value','number_value','boolean_value','string_value')
;



END //
