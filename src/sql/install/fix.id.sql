delimiter ;
update
    `ds_column`
set
    `is_primary` = 1
where
   `column_name` = 'id'
    and table_name in (
        select table_name from (
            select
                table_name,
                sum(`is_primary`) s
            from
                `ds_column`
            where
                `table_name` = 'view_ds_listfilters'
        ) as s where s.s = 0
);
