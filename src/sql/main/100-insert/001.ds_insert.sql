DELIMITER //

DROP FUNCTION IF EXISTS `ds_serial` //
CREATE FUNCTION `ds_serial`( request JSON )
RETURNS LONGTEXT
DETERMINISTIC
BEGIN 
    DECLARE serialsql LONGTEXT;
    DECLARE use_table_name varchar(128);
    DECLARE fields JSON;

    SET use_table_name = JSON_VALUE(request,'$.data.__table_name');
    SET fields = JSON_KEYS(JSON_EXTRACT(request,'$.data'));

    SELECT 
        fn_serial_sql(table_name,column_name)
    INTO serialsql
    FROM 
        ds_column 
    WHERE 
        ds_column.table_name = use_table_name
        and ds_column.writeable=1
        and ( 
            JSON_SEARCH(fields,'one',concat(table_name,'__',column_name)) is not null
            and default_value = '{#serial}'
        )
    ;
    IF serialsql is null THEN 
        SET serialsql='SET @serial=0;';
    END IF;
    RETURN serialsql;

END //

CREATE OR REPLACE FUNCTION `ds_insert`( request JSON )
RETURNS LONGTEXT
DETERMINISTIC
BEGIN 
    DECLARE res LONGTEXT;

    DECLARE i int;
    DECLARE row_count int;

    DECLARE use_id varchar(255);
    DECLARE use_table_name varchar(128);
    DECLARE fields JSON;
    

    SET use_table_name = JSON_VALUE(request,'$.data.__table_name');
    SET fields = JSON_KEYS(JSON_EXTRACT(request,'$.data'));



    SELECT 
        
        concat(
            'INSERT ',if(@ds_insert_ignore is not null and @ds_insert_ignore=true,'IGNORE',''),' INTO `',use_table_name,'`',
            ' (',
            group_concat( concat('`',column_name,'`') separator ','),
            ')  values (  ',
            group_concat(   val  separator ','),
            ')    ',
            if(@ds_insert_update_on_duplicate_key is not null and @ds_insert_update_on_duplicate_key=true,
            concat( 'on duplicate key update ',group_concat( concat('`',column_name,'`','=values(`',column_name,'`)') separator ','))
            ,'')
        ) x
    INTO
        res
    FROM 
    (

        SELECT 
            -- concat(table_name,'__',column_name) attribute,
            ds_column.column_name,
            IF(
                ( 
                    JSON_SEARCH(fields,'one',concat(table_name,'__',column_name)) is not null 
                    and JSON_VALUE( JSON_EXTRACT(request,'$.data'), concat('$.',table_name,'__',column_name,'')) <>'null'
					and JSON_VALUE( JSON_EXTRACT(request,'$.data'), concat('$.',table_name,'__',column_name,'')) <> default_value

                ),
                quote( JSON_VALUE( JSON_EXTRACT(request,'$.data'), concat('$.',table_name,'__',column_name,'')) ),
                IF(
                    default_value<>'',
                    fn_ds_defaults(default_value,JSON_EXTRACT(request,'$.data')),
                    if( JSON_VALUE( JSON_EXTRACT(request,'$.data'), concat('$.',table_name,'__',column_name,'')) <>'null',
                    
                    if(
                         JSON_VALUE( JSON_EXTRACT(request,'$.data'), concat('$.',table_name,'__',column_name,'')) <>'null',
                         quote(JSON_VALUE( JSON_EXTRACT(request,'$.data'), concat('$.',table_name,'__',column_name,'')))
                         ,'null'
                    )
                    
                    , quote(''))
                )
            ) val
        FROM 
            ds_column 
        WHERE 
            ds_column.table_name = use_table_name
            and ds_column.existsreal=1
            and ds_column.writeable=1
            and ( 
                JSON_SEARCH(fields,'one',concat(table_name,'__',column_name)) is not null
                -- OR is_nullable<>'YES'
                -- OR default_value <> ''
            )
    ) X
    ;
    RETURN res;
END //
