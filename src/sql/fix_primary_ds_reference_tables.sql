delimiter  //


CREATE OR REPLACE PROCEDURE `fix_primary_ds_reference_tables`( )
BEGIN 

set @pri = (select count(*) x from information_schema.columns   where table_schema = database() and table_name = 'ds_reference_tables' and column_key = 'PRI');

if @pri = 0 then
    create temporary table if not exists ds_reference_tables_tmp 
    as
    select
        table_name,
        reference_table_name,
        columnsdef,
        constraint_name,
        max(active) active,
        searchable,
        autosync,
        position,
        path,
        existsreal,
        tabtitle
    from 
    ds_reference_tables
    group by constraint_name;
    delete from ds_reference_tables;
    insert into ds_reference_tables
    select * from ds_reference_tables_tmp;
    -- drop table ds_reference_tables_tmp;
    alter table ds_reference_tables add primary key (constraint_name);
    call fill_ds('');
end if;

END //

call fix_primary_ds_reference_tables() //