delimiter ;

create view if not exists view_ds_store_sort_directions as 
select 'ASC' as id, 'Aufsteigend' as name
union all
select 'DESC' as id, 'Absteigend' as name;