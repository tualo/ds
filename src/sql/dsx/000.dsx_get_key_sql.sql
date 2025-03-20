DELIMITER //


CREATE OR REPLACE FUNCTION `dsx_get_key_sql_prefix`(in_prefix varchar(255),in_table_name varchar(64)
) RETURNS longtext
    DETERMINISTIC
BEGIN 
    declare prefix_separator varchar(3) default '';
    if in_prefix <> '' then
        set prefix_separator = '.';
    end if;
    RETURN ( 

        with c as (
            select 
                count(column_name) c
            from 
                    ds_column
                where 
                    ds_column.table_name = in_table_name
                    and ds_column.existsreal = 1
                    and ds_column.is_generated <> 'ALWAYS'
                    and ds_column.is_primary = 1
        )

        select 
                if (c=1,
                    ifnull(concat(' ',group_concat(concat(in_prefix,prefix_separator, FIELDQUOTE(ds_column.column_name),'') order by column_name separator ',\'|\','),' '),'null'),
                    ifnull(concat('concat(',group_concat(concat(in_prefix,prefix_separator, FIELDQUOTE(ds_column.column_name),'') order by column_name separator ',\'|\','),')'),'null')
                
                ) xy
                from 
                    ds_column join c
                where 
                    ds_column.table_name = in_table_name
                    and ds_column.existsreal = 1
                    and ds_column.is_generated <> 'ALWAYS'
                    and ds_column.is_primary = 1
                    
    /*                    
        select 
            ifnull(concat('concat(',group_concat(concat(in_prefix,'.', FIELDQUOTE(ds_column.column_name),'') order by column_name separator ',\'|\','),')'),'null')
        from 
            ds_column
        where 
            ds_column.table_name = in_table_name
            and ds_column.existsreal = 1
            
            and ds_column.is_generated <> 'ALWAYS'
            and ds_column.is_primary = 1
            */
    );
END //



CREATE OR REPLACE FUNCTION `dsx_get_key_sql`(in_table_name varchar(64)
) RETURNS longtext
    DETERMINISTIC
BEGIN 
    RETURN dsx_get_key_sql_prefix('',in_table_name);
END //



CREATE OR REPLACE FUNCTION `dsx_get_key_sql_plain`(in_prefix varchar(255),in_table_name varchar(64)
) RETURNS longtext
    DETERMINISTIC
BEGIN 
    RETURN ( 
        select 
            ifnull(concat('',group_concat(concat(in_prefix,'.', FIELDQUOTE(ds_column.column_name),'') order by column_name separator ','),''),'null')
        from 
            ds_column
        where 
            ds_column.table_name = in_table_name
            and ds_column.existsreal = 1
            and ds_column.is_generated <> 'ALWAYS'
            and ds_column.is_primary = 1
            
    );
END //