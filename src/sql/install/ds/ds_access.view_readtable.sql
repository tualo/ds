DELIMITER;


CREATE OR REPLACE VIEW `view_readtable_ds_access_all` AS 
select 
    ds.table_name AS `table_name`,
    VIEW_SESSION_GROUPS.group  AS `role`,
    ifnull(`tc`.`read`,0) AS `read`,
    ifnull(`tc`.`write`,0) AS `write`,
    ifnull(`tc`.`append`,0) AS `append`,
    ifnull(`tc`.`delete`,0) AS `delete` 
from 
VIEW_SESSION_GROUPS
join ds
left join ds_access tc 
on ds.table_name = tc.table_name
and VIEW_SESSION_GROUPS.group = tc.`role`
;