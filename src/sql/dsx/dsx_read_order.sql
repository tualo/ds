DELIMITER //
DROP FUNCTION IF EXISTS dsx_read_order //
CREATE OR REPLACE FUNCTION `dsx_read_order`( request JSON )
RETURNS longtext
DETERMINISTIC
BEGIN 
    

    RETURN (
        select 
            group_concat( concat(/*'`',JSON_VALUE(request,'$.tablename')'`','.',*/  '`',property,'` ',direction) separator ',' ) X
        from 
        (
        SELECT
            ds.sortfield property,
            'asc' direction
        FROM
        ds
        join ds_column 
            on (ds_column.table_name, ds_column.column_name) = (ds.table_name, ds.sortfield)
            and ds.table_name = JSON_VALUE(request,'$.tablename')
            and ds_column.existsreal=1 and false

        union 
        select 
            REGEXP_REPLACE(property,concat('^',JSON_VALUE(request,'$.tablename'),'__'),'') property,
            direction
        from

        JSON_TABLE(json_extract(request,'$.sort'), '$[*]'  COLUMNS (

                property varchar(128) path '$.property',
                direction  varchar(5) path '$.direction'
                
            ) ) as jt

        ) SORT_TABLE

    );
END //
/*
set @request = '
{
    "replaced": 1,
    "count": 1,
    "page": 1,
    "limit": 50,
    "rownumber": 1,
    "returnfields": ["kundennummer","plz"],
    "sort": [
        {"property":"adressen__plz","direction":"desc"},
        {"property":"kundennummer","direction":"asc"},
        {"property":"kostenstelle","direction":"desc"}
    ],
    "tablename": "adressen",
    "filter":[{"operator":"eq","value":"07545","property":"adressen__plz"}]
}
' //

-- select dsx_read_order(@request) //
*/