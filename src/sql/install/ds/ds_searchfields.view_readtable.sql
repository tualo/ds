delimiter ;

create or replace view `view_readtable_ds_searchfields` as

select 
    ifnull(ds_searchfields.active,0) active,
    ds_column.table_name,
    ds_column.column_name
from 
    ds_column
    left join ds_searchfields
        on (ds_searchfields.table_name,ds_searchfields.column_name)  = (ds_column.table_name,ds_column.column_name)
;