delimiter ;

create or replace view view_readtable_ds_types as

-- DS Store
select 
    concat('Tualo.DataSets.store.',UCASE(LEFT(`ds`.`table_name`, 1)), lower(SUBSTRING(`ds`.`table_name`, 2))) `id`,
    concat('store.ds_',`ds`.`table_name`) `xtype_long_modern`,
    concat('store.ds_',`ds`.`table_name`) `xtype_long_classic`,

    'store' `modern_typeclass`,
    concat('ds_',`ds`.`table_name`) `modern_type`,

    'store' `classic_typeclass`,
    concat('ds_',`ds`.`table_name`) `classic_type`,

    concat('Datastore ',`ds`.`title`,' (',`ds`.`table_name`,')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    0 isformfield,
    0 iscolumn

    

from `ds` 
join ( 
        select `table_name` 
        from `ds_access` join `view_session_groups` on `ds_access`.`role` = `view_session_groups`.`group` and  `ds_access`.`read`=1 
        group by  `table_name` 
    ) `acc` on `acc`.`table_name` = `ds`.`table_name`
where `ds`.`title`<>''

union all


-- DS List
select 
    concat('Tualo.DataSets.list.',UCASE(LEFT(`ds`.`table_name`, 1)), lower(SUBSTRING(`ds`.`table_name`, 2))) `id`,
    concat('widget.dslist_',`ds`.`table_name`) `xtype_long_modern`,
    concat('widget.dslist_',`ds`.`table_name`) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    concat('dslist_',`ds`.`table_name`) `modern_type`,

    'widget' `classic_typeclass`,
    concat('dslist_',`ds`.`table_name`) `classic_type`,

    concat('DS List ',`ds`.`title`,' (',`ds`.`table_name`,')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    0 isformfield,
    0 iscolumn

from `ds` 
join ( 
        select `table_name` 
        from `ds_access` join `view_session_groups` on `ds_access`.`role` = `view_session_groups`.`group` and  `ds_access`.`read`=1 
        group by  `table_name` 
    ) `acc` on `acc`.`table_name` = `ds`.`table_name`
where `ds`.`title`<>''

union all

-- DS Form
select 
    concat('Tualo.DataSets.form.',UCASE(LEFT(`ds`.`table_name`, 1)), lower(SUBSTRING(`ds`.`table_name`, 2))) `id`,
    concat('widget.dsform_',`ds`.`table_name`) `xtype_long_modern`,
    concat('widget.dsform_',`ds`.`table_name`) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    concat('dsform_',`ds`.`table_name`) `modern_type`,

    'widget' `classic_typeclass`,
    concat('dsform_',`ds`.`table_name`) `classic_type`,

    concat('DS Form ',`ds`.`title`,' (',`ds`.`table_name`,')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    1 isformfield,
    0 iscolumn

from `ds` 
join ( 
        select `table_name` 
        from `ds_access` join `view_session_groups` on `ds_access`.`role` = `view_session_groups`.`group` and  `ds_access`.`read`=1 
        group by  `table_name` 
    ) `acc` on `acc`.`table_name` = `ds`.`table_name`
where `ds`.`title`<>''
    

union all

-- DS Column
select 
    concat('Tualo.DataSets.column.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ) `id`,
    concat('widget.column_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_modern`,
    concat('widget.column_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    concat('column_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `modern_type`,

    'widget' `classic_typeclass`,
    concat('column_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `classic_type`,

    concat('DS Column ',`ds`.`title`,'-',ds_dropdownfields.name,' (',`ds`.`table_name`,' ',lower(ds_dropdownfields.name),')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    0 isformfield,
    1 iscolumn

from
    `ds_dropdownfields`
    join `ds` 
        on `ds_dropdownfields`.`table_name` = `ds`.`table_name`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1
    join ( 
        select `table_name` 
        from `ds_access` join `view_session_groups` on `ds_access`.`role` = `view_session_groups`.`group` and  `ds_access`.`read`=1 
        group by  `table_name` 
    ) `acc` on `acc`.`table_name` = `ds`.`table_name`
union  all
-- DS Displayfield
select 
    concat('Tualo.DataSets.displayfield.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ) `id`,
    concat('widget.displaycombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_modern`,
    concat('widget.displaycombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    concat('displaycombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `modern_type`,

    'widget' `classic_typeclass`,
    concat('displaycombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `classic_type`,

    concat('DS DisplayField ',`ds`.`title`,'-',ds_dropdownfields.name,' (',`ds`.`table_name`,' ',lower(ds_dropdownfields.name),')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    1 isformfield,
    0 iscolumn

from
    `ds_dropdownfields`
    join `ds` 
        on `ds_dropdownfields`.`table_name` = `ds`.`table_name`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1

union  all


select 
    concat('Tualo.DataSets.displaylinkedfield.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ) `id`,
    concat('widget.displaylinkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_modern`,
    concat('widget.displaylinkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    concat('displaylinkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `modern_type`,

    'widget' `classic_typeclass`,
    concat('displaylinkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `classic_type`,

    concat('DS LinkedDisplayField ',`ds`.`title`,'-',ds_dropdownfields.name,' (',`ds`.`table_name`,' ',lower(ds_dropdownfields.name),')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    1 isformfield,
    0 iscolumn

from
    `ds_dropdownfields`
    join `ds` 
        on `ds_dropdownfields`.`table_name` = `ds`.`table_name`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1

union  all

-- DS DD Field
select 
    concat('Tualo.DataSets.combobox.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ) `id`,
    concat('widget.combobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_modern`,
    concat('widget.combobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    concat('combobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `modern_type`,

    'widget' `classic_typeclass`,
    concat('combobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `classic_type`,

    concat('DS ComboBox ',`ds`.`title`,'-',ds_dropdownfields.name,' (',`ds`.`table_name`,' ',lower(ds_dropdownfields.name),')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    1 isformfield,
    0 iscolumn

from
    `ds_dropdownfields`
    join `ds` 
        on `ds_dropdownfields`.`table_name` = `ds`.`table_name`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1
join ( 
        select `table_name` 
        from `ds_access` join `view_session_groups` on `ds_access`.`role` = `view_session_groups`.`group` and  `ds_access`.`read`=1 
        group by  `table_name` 
    ) `acc` on `acc`.`table_name` = `ds`.`table_name`


union  all

-- DS DD Field
select 
    concat('Tualo.DataSets.linkedcombobox.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ) `id`,
    concat('widget.linkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_modern`,
    concat('widget.linkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    concat('linkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `modern_type`,

    'widget' `classic_typeclass`,
    concat('linkedcombobox_',`ds_dropdownfields`.`table_name`,'_',lower(ds_dropdownfields.name)) `classic_type`,

    concat('DS LinkedComboBox ',`ds`.`title`,'-',ds_dropdownfields.name,' (',`ds`.`table_name`,' ',lower(ds_dropdownfields.name),')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    1 isformfield,
    0 iscolumn

from
    `ds_dropdownfields`
    join `ds` 
        on `ds_dropdownfields`.`table_name` = `ds`.`table_name`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1
join ( 
        select `table_name` 
        from `ds_access` join `view_session_groups` on `ds_access`.`role` = `view_session_groups`.`group` and  `ds_access`.`read`=1 
        group by  `table_name` 
    ) `acc` on `acc`.`table_name` = `ds`.`table_name`



union  all

-- DS columnfilter
select 
    concat('Tualo.DataSets.grid.filters.filter.',lower(ds_dropdownfields.table_name),'.',UCASE(LEFT(ds_dropdownfields.name, 1)), lower(SUBSTRING(ds_dropdownfields.name, 2))  ) `id`,
    concat('grid.filter.',lower(concat(ds_dropdownfields.table_name,'_',ds_dropdownfields.name,'_listfilter'))) `xtype_long_modern`,
    concat('grid.filter.',lower(concat(ds_dropdownfields.table_name,'_',ds_dropdownfields.name,'_listfilter'))) `xtype_long_classic`,

    'widget' `modern_typeclass`,
    lower(concat(ds_dropdownfields.table_name,'_',ds_dropdownfields.name,'_listfilter')) `modern_type`,

    'widget' `classic_typeclass`,
    lower(concat(ds_dropdownfields.table_name,'_',ds_dropdownfields.name,'_listfilter')) `classic_type`,

    concat('DS Columnfilter ',`ds`.`title`,'-',ds_dropdownfields.name,' (',`ds`.`table_name`,' ',lower(ds_dropdownfields.name),')') `name`,
    'Tualo DS' `vendor`,
    '' `description`,
    0 isformfield,
    0 iscolumn

from
    `ds_dropdownfields`
    join `ds` 
        on `ds_dropdownfields`.`table_name` = `ds`.`table_name`
    join `ds_column` 
        on (`ds_dropdownfields`.`table_name`,`ds_dropdownfields`.`idfield`) = (`ds_column`.`table_name`,`ds_column`.`column_name`)
        and `ds_column`.`existsreal`=1
join ( 
        select `table_name` 
        from `ds_access` join `view_session_groups` on `ds_access`.`role` = `view_session_groups`.`group` and  `ds_access`.`read`=1 
        group by  `table_name` 
    ) `acc` on `acc`.`table_name` = `ds`.`table_name`
;





create or replace view view_readtable_all_types as
        select `name` as `id`,`xtype_long_modern`,`xtype_long_classic`,`modern_typeclass`,`modern_type`,`classic_typeclass`,`classic_type`,`name`,`vendor`,`description` from view_readtable_extjs_base_types
union   select `id`,`xtype_long_modern`,`xtype_long_classic`,`modern_typeclass`,`modern_type`,`classic_typeclass`,`classic_type`,`name`,`vendor`,`description` from view_readtable_custom_types
union   select `id`,`xtype_long_modern`,`xtype_long_classic`,`modern_typeclass`,`modern_type`,`classic_typeclass`,`classic_type`,`name`,`vendor`,`description` from view_readtable_ds_types
;

create or replace view view_readtable_all_types_modern as
select `id`,`xtype_long_modern` `xtype`,`modern_typeclass` `typeclass`,`modern_type` `type`,`name`,`vendor`,`description`
from view_readtable_all_types where  xtype_long_modern is not null  
;

create or replace view view_readtable_all_types_classic as
select `id`,`xtype_long_classic` `xtype`,`classic_typeclass` `typeclass`,`classic_type` `type`,`name`,`vendor`,`description`
from view_readtable_all_types where  xtype_long_classic is not null  
group by `classic_type`
;


-- ds_dropdownfields