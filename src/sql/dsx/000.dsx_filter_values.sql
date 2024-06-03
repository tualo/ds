DELIMITER //

CREATE OR REPLACE FUNCTION `dsx_filter_term`(tablename varchar(128), filter_object JSON ) 
RETURNS longtext 
    DETERMINISTIC
BEGIN 
    RETURN (
       
    select 
        concat('(',
            group_concat(
                concat(
                    `property`,
                    ' ',`operator`,' ',
                    `value` 
                )
                separator ''
            ),
        ')')
    from (

        select 
                    
            `property`, 
            dsx_filter_operator(`operator`) `operator`,
            dsx_filter_values_extract(`value`,data_type) `value`

        from
        (
        select
            REGEXP_REPLACE(property,concat('^',tablename,'__'),'') `property`, -- remove OLD style queries
            `operator`,
            `value`
        from

            JSON_TABLE(
                JSON_MERGE(json_array(),filter_object), '$[*]'  
                COLUMNS (
                    `property` varchar(128) path '$.property',
                    `operator` varchar(15) path '$.operator',
                    `value`    JSON path '$.value'
                ) 
            ) as jtx
            
        ) jt
        join ds_column 
            on (ds_column.column_name = jt.property)
            and ds_column.table_name  = tablename
         -- ACHTUNG __ID Property abfragen  UNION
         
    ) A);
END //

CREATE OR REPLACE FUNCTION `dsx_filter_values_simple`( request JSON ) 
RETURNS longtext 
    DETERMINISTIC
BEGIN 
    DECLARE concat_by varchar(20);
    IF JSON_VALUE(request,'$.concat_by') is null THEN set request=JSON_SET(request,'$.concat_by','and'); END IF;
    SET concat_by = concat(' ',JSON_VALUE(request,'$.concat_by' ),' ');
    RETURN (


        select 
            replace(
                group_concat(
                    concat(
                        `property`,
                        ' ',`operator`,' ',
                        `value` 
                    )
                    separator '##########'
                ),
                '##########',
                concat_by
            )
        FROM
         
        (

            
            select 
                
                concat('`',REGEXP_REPLACE(`property`,concat('^',JSON_VALUE(request,'$.tablename'),'__'),''),'`') `property`,
                dsx_filter_operator(`operator`) `operator`,
                dsx_filter_values_extract(`value`,ds_column.data_type) `value`
            from
            (
                select
                    REGEXP_REPLACE(property,concat('^',JSON_VALUE(request,'$.tablename'),'__'),'') `property`,
                    `operator`,
                    `value`
                from

                    JSON_TABLE(json_extract(request,'$.filter'), '$[*]'  COLUMNS (

                        `property` varchar(128) path '$.property',
                        `operator` varchar(15) path '$.operator',
                        `value`    JSON path '$.value'
                        
                    ) 
                ) as jtx
                where `property` is not null
            ) jt

            join ds_column 
                on (ds_column.column_name=jt.property)
                and ds_column.table_name =json_value(request,'$.tablename')

            union


            select 
                dsx_get_key_sql(ds_column.table_name) `property`,
                dsx_filter_operator(`operator`) `operator`,
                dsx_filter_values_extract(`value`,ds_column.data_type) `value`
            from
            (
                select
                    REGEXP_REPLACE(property,concat('^',JSON_VALUE(request,'$.tablename'),'__'),'') `property`,
                    `operator`,
                    `value`
                from

                    JSON_TABLE(json_extract(request,'$.filter'), '$[*]'  COLUMNS (

                        `property` varchar(128) path '$.property',
                        `operator` varchar(15) path '$.operator',
                        `value`    JSON path '$.value'
                        
                    ) 
                ) as jtx
            ) jt

            join ds_column 
                on 
                
                `property` = '__id'
                and ds_column.table_name = json_value(request,'$.tablename')
                and ds_column.is_primary = 1
                and ds_column.existsreal = 1
        ) FILTER_TABLE

    );
END //


CREATE OR REPLACE FUNCTION `dsx_filter_values`( request JSON , ftype varchar(20)) 
RETURNS longtext 
    DETERMINISTIC
BEGIN 
    DECLARE concat_by varchar(20);
    DECLARE filterObject JSON;

    SET request = JSON_QUERY(request,'$');
    IF JSON_VALUE(request,'$.concat_by') is null THEN set request=JSON_SET(request,'$.concat_by','and'); END IF;
    SET concat_by = concat(' ',JSON_VALUE(request,'$.concat_by' ),' ');


    SET filterObject = JSON_EXTRACT(request,concat('$.',ftype));
    IF JSON_TYPE(filterObject)<>'ARRAY' THEN
      SET filterObject = JSON_VALUE(request,concat('$.',ftype));
    END IF;

    RETURN (


        select 
            replace(
                group_concat(
                    concat(
                        `property`,
                        ' ',`operator`,' ',
                        `value` 
                    )
                    separator '##########'
                ),
                '##########',
                concat_by
            )
        FROM
         
        (

            
            select 
                
                concat('`',REGEXP_REPLACE(`property`,concat('^',JSON_VALUE(request,'$.tablename'),'__'),''),'`') `property`,
                dsx_filter_operator(`operator`) `operator`,
                dsx_filter_values_extract(`value`,ds_column.data_type) `value`
            from
            (
                select
                    REGEXP_REPLACE(property,concat('^',JSON_VALUE(request,'$.tablename'),'__'),'') `property`,
                    `operator`,
                    `value`
                from

                    JSON_TABLE(filterObject, '$[*]'  COLUMNS (

                        `property` varchar(128) path '$.property',
                        `operator` varchar(15) path '$.operator',
                        `value`    JSON path '$.value'
                        
                    ) 
                ) as jtx
                where 
                    `property` is not null
                    and `value` is not null
            ) jt

            join ds_column 
                on (ds_column.column_name=jt.property)
                and ds_column.table_name =json_value(request,'$.tablename')
                and `property` <> '__id'

            union


            select 
                dsx_get_key_sql( JSON_VALUE(request,'$.tablename') ) `property`,
                dsx_filter_operator(`operator`) `operator`,
                dsx_filter_values_extract(`value`,'varchar') `value`
            from
            (
                select
                    REGEXP_REPLACE(property,concat('^',JSON_VALUE(request,'$.tablename'),'__'),'') `property`,
                    `operator`,
                    `value`
                from

                    JSON_TABLE(filterObject, '$[*]'  COLUMNS (

                        `property` varchar(128) path '$.property',
                        `operator` varchar(15) path '$.operator',
                        `value`    JSON path '$.value'
                        
                    ) 
                ) as jtx
                where 
                    `property` is not null
                                    and `value` is not null
            ) jt

            where    `property` = '__id'
                -- and ds_column.table_name = json_value(request,'$.tablename')
                -- and ds_column.is_primary = 1


            
            union


            select
                    '' `property`,
                    '' `operator`,
                    concat( 
                        '(',
                        dsx_filter_values_simple( 
                            JSON_OBJECT(
                                "tablename",json_extract(request,'$.tablename'),
                                "concat_by", ifnull(jtx.concat_by,'and'),
                                "filter", JSON_MERGE(JSON_ARRAY(),`filter`)
                            ) 
                        ),
                        ')'
                    ) `value`
                from
                    JSON_TABLE(filterObject, '$[*]'  COLUMNS (
                        `concat_by` longtext path '$.concat_by',
                        `filter`    JSON path '$.filter'
                    ) 
                ) as jtx
            where jtx.filter!='NULL' -- keep in mind, JSON TYPE NULL


        union


        select
            if(`property` <> '__id',`property`,dsx_get_key_sql( JSON_VALUE(request,'$.tablename') )) `property`,
            `operator`,
            concat('(',group_concat(quote(`value`) separator ','),')') `value`
        from (
            select
                REGEXP_REPLACE(property,concat('^',JSON_VALUE(request,'$.tablename'),'__'),'') `property`,
                `operator`,
                `value`
            from

                JSON_TABLE( filterObject , '$[*]'  COLUMNS (

                        `property` varchar(128) path '$.property',
                        `operator` varchar(15) path '$.operator',
                                
                        nested path '$.value[*]' columns (
                            `value` longtext path '$'
                        )
                        
                    ) 
                ) as jtx
            where 
            `value` is not null
            
            and `property` is not null
            and `operator` in ('in','not in')
        ) c group by        
            `property`,
            `operator`    

        ) FILTER_TABLE
/*
        union


            
*/
    );
END //

set @request = '
{
    "replaced": 1,
    "count": 1,
    "page": 1,
    "limit": 50,
    "rownumber": 1,
    "returnfields": ["kundennummer","plz"],
    "sort": [
        {
            "property":"adressen__plz",
            "direction":"desc"
        }
    ],
    "tablename": "adressen",
    "filter":[
        {
                "operator":"eq",
                "value":"07545",
                "property":"adressen__plz"
        },
        {       "operator":"like",
                "value":"%12%",
                "property":"__id"
        },
        {
            "operator": "or term",
            "value": [
                {
                    "operator":"like",
                    "value":"%Test%",
                    "property":"adressen__name"
                },
                {   
                    "operator":"eq",
                    "value":"Muster",
                    "property":"adressen__firma"
                }
            ] 
        }
        
    ]
}
' //
 select dsx_filter_values(@request,'filter') //

/*
    select
        '' `property`,
        '' `operator`,
        concat( 
            '(',
            dsx_filter_values( 
                JSON_OBJECT(
                    "tablename",json_extract(@request,'$.tablename'),
                    "concat_by", ifnull(jtx.concat_by,'and'),
                    "filter", JSON_MERGE(JSON_ARRAY(),`filter`)
                ) 
            ),
            ')'
        ) `value`
    from
        JSON_TABLE(json_extract(@request,'$.filter'), '$[*]'  COLUMNS (
            `concat_by` longtext path '$.concat_by',
            `filter`    JSON path '$.filter'
        ) 
    ) as jtx
    where jtx.filter!='NULL' -- keep in mind, JSON TYPE NULL

//

*/

-- select dsx_filter_term('adressen',JSON_EXTRACT(@request,'$.filter[0]')) //

