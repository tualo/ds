DELIMITER //
DROP FUNCTION IF EXISTS getDSKeySQL //
CREATE FUNCTION getDSKeySQL(
    in_table_name varchar(64)
) 
RETURNS longtext
DETERMINISTIC
BEGIN 
    DECLARE result_sql longtext;
    select 
        ifnull(concat('concat(',group_concat(concat(/*'`',ds_column.table_name,'`','.',*/ FIELDQUOTE(ds_column.column_name),'') order by column_name separator ',\'|\','),')'),'null')
    into 
        result_sql
    from 
        ds_column
    where 
        ds_column.table_name = in_table_name
        and ds_column.existsreal = 1
        and ds_column.is_primary = 1
        -- and ds_column.column_key like '%PRI%'
    ;

    return result_sql;
END //

