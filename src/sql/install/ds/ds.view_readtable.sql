DELIMITER ;
CREATE OR REPLACE VIEW  `view_readtable_ds` AS
select 
    *
from 
    `ds`
where
    `table_name` not like 'mv%'
    and `table_name` not like 'ds_query%'
    and `table_name` not like 'view_readtable%'
    and `table_name` not like '%_doc'
    and `table_name` not like '%_doc_data'
    and `table_name` not like '%_docdata'
    and `table_name` not in ('ds_sync_lock','ds_sync_hstrtable_lock','ds_sync_remove','log_ds_sync')
;
