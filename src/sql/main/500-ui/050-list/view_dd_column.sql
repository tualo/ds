delimiter ;

create or replace view view_tualo_available_types as 

select 
    `id`,
    `xtype_long_modern`,
    `xtype_long_classic`,

    `name`,
    `vendor`,
    `description`,
    
    SUBSTRING_INDEX(`xtype_long_modern`, '.', 1) `modern_typeclass`,
    SUBSTRING_INDEX(`xtype_long_modern`, '.', -1) `modern_type`,

    SUBSTRING_INDEX(`xtype_long_classic`, '.', 1) `classic_typeclass`,
    SUBSTRING_INDEX(`xtype_long_classic`, '.', -1) `classic_type`,

        iscolumn,
        isformfield


from extjs_base_types where isformfield=1 or iscolumn=1

union  all

select 

    `id`,
    `xtype_long_modern`,
    `xtype_long_classic`,

    `name`,
    `vendor`,
    `description`,

        modern_typeclass,
        modern_type,
        
        classic_typeclass,
        classic_type,
        
        iscolumn,
        isformfield


from view_readtable_ds_types
;


create or replace view view_tualo_form_fields as 
select * from view_tualo_available_types 
where isformfield = 1
;


create or replace view view_tualo_column_types as 
select * from view_tualo_available_types 
where iscolumn=1
;

call fill_ds('view_tualo_form_fields');
call fill_ds_column('view_tualo_form_fields');
call fill_ds('view_tualo_column_types');
call fill_ds_column('view_tualo_column_types');
