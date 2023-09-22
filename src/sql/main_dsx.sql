


-- SOURCE FILE: ./src//000.dsx_filter_values.sql 
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


-- SOURCE FILE: ./src//000.dsx_filter_values_extract.sql 
DELIMITER //
CREATE OR REPLACE FUNCTION `dsx_filter_values_extract`( request JSON,  dtype varchar(36) )
RETURNS LONGTEXT
DETERMINISTIC
BEGIN 
    DECLARE _type varchar(36);
    DECLARE i int;
    DECLARE row_count int;
    DECLARE result LONGTEXT default '';
    DECLARE term LONGTEXT default '';

    IF JSON_VALID(request)=0 THEN 
        RETURN doublequote(request);
    END IF;
    
    SET _type = JSON_TYPE( request );
    IF (_type IS NULL ) THEN RETURN 'NULL'; END IF;
    IF (_type='STRING') THEN RETURN  JSON_QUOTE(JSON_UNQUOTE(request)); END IF;
    IF (_type='BLOB') THEN RETURN JSON_QUOTE(JSON_UNQUOTE(request)); END IF;
    IF (_type='BOOLEAN') THEN 
        IF (JSON_VALUE(request,'$')=TRUE) THEN 
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END IF;

    IF (_type='DECIMAL') THEN RETURN JSON_VALUE(request,'$'); END IF;
    IF (_type='DOUBLE') THEN RETURN JSON_VALUE(request,'$'); END IF;
    IF (_type='INTEGER') THEN RETURN JSON_VALUE(request,'$'); END IF;
    IF (_type='NULL') THEN RETURN 'NULL'; END IF;
    IF (_type='DECIMAL') THEN RETURN JSON_VALUE(request,'$'); END IF;
    IF (_type='OBJECT') OR (_type='OPAQUE') THEN 
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Object Type is not allowed as value';
    END IF;
    IF (_type='DATE') THEN RETURN JSON_QUOTE(JSON_VALUE(request,'$')); END IF;
    IF (_type='DATETIME') THEN RETURN  JSON_QUOTE(JSON_VALUE(request,'$')); END IF;
    IF (_type='TIME') THEN RETURN JSON_QUOTE(JSON_VALUE(request,'$')); END IF;
    IF (_type='BIT') THEN RETURN JSON_QUOTE(JSON_VALUE(request,'$')); END IF;
    IF (_type='ARRAY') THEN 
        SET row_count = JSON_LENGTH(request);
        SET i = 0;
        WHILE i < row_count DO
            SET term= JSON_QUOTE(JSON_VALUE(request,CONCAT('$[',i,']')));
            IF term is not null  THEN
                IF result<>'' THEN SET result = concat(result,', '); END IF;
                SET result = concat(result,term);
            END IF;
            SET i = i + 1;
        END WHILE;
        SET result = concat('(',result,')');
    END IF;
    return result;

END //
-- SOURCE FILE: ./src//000.dsx_get_key_sql.sql 
DELIMITER //
CREATE OR REPLACE FUNCTION `dsx_get_key_sql`(in_table_name varchar(64)
) RETURNS longtext
    DETERMINISTIC
BEGIN 
    RETURN ( 
        select 
            ifnull(concat('concat(',group_concat(concat( FIELDQUOTE(ds_column.column_name),'') order by column_name separator ',\'|\','),')'),'null')
        from 
            ds_column
        where 
            ds_column.table_name = in_table_name
            and ds_column.existsreal = 1
            and ds_column.is_primary = 1
            
    );
END //


CREATE OR REPLACE FUNCTION `dsx_get_key_sql_prefix`(in_prefix varchar(255),in_table_name varchar(64)
) RETURNS longtext
    DETERMINISTIC
BEGIN 
    RETURN ( 
        select 
            ifnull(concat('concat(',group_concat(concat(in_prefix,'.', FIELDQUOTE(ds_column.column_name),'') order by column_name separator ',\'|\','),')'),'null')
        from 
            ds_column
        where 
            ds_column.table_name = in_table_name
            and ds_column.existsreal = 1
            and ds_column.is_primary = 1
            
    );
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
            and ds_column.is_primary = 1
            
    );
END //
-- SOURCE FILE: ./src//001.dsx_filter_operator.sql 
DELIMITER //
CREATE OR REPLACE FUNCTION `dsx_filter_operator`(operator varchar(128))
RETURNS varchar(128)
DETERMINISTIC
BEGIN 
    DECLARE result varchar(128) default '=';
    
    IF operator='==' or operator='eq' THEN SET result='='; END IF;
    IF operator='!=' or operator='not' THEN SET result='<>'; END IF;
    IF operator='>=' or operator='gt' THEN SET result='>='; END IF;
    IF operator='<=' or operator='lt' THEN SET result='<='; END IF;
    IF operator='not like' THEN SET result='not like'; END IF;
    IF operator='like' THEN SET result='like'; END IF;
    IF operator='in' THEN SET result='in'; END IF;
    IF operator='not in' THEN SET result='not in'; END IF;
    RETURN result;
END //
-- SOURCE FILE: ./src//create_or_upgrade_hstr_table.sql 
DELIMITER //
CREATE OR REPLACE PROCEDURE `create_or_upgrade_hstr_table`( IN tablename varchar(128))
BEGIN 
    SET @cmd = concat('create table if not exists `',tablename,'_hstr`(
           hstr_sessionuser VARCHAR(150) DEFAULT "",
           hstr_action varchar(8) NOT NULL default "insert",
           hstr_revision varchar(36) NOT NULL PRIMARY KEY,
           hstr_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )');
    call fill_ds(concat('',tablename,'_hstr'));
    call fill_ds_column(concat('',tablename,'_hstr'));
    PREPARE stmt FROM @cmd;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @fldColumns = (
        select group_concat( concat('`',column_name,'`') order by column_name separator ',')
        from ds_column where ds_column.table_name = tablename and existsreal=1 
        and writeable=1
    );
    
    SET @priColumns = (
        select group_concat( concat('`',column_name,'`') order by column_name separator ',')
        from ds_column where ds_column.table_name = tablename and existsreal=1 and is_primary=1
        and writeable=1
    );

    SET @where = (
        select group_concat( concat('`',column_name,'` = NEW.`',column_name,'`') order by column_name separator ' and ')
        from ds_column where ds_column.table_name = tablename and existsreal=1 and is_primary=1
        and writeable=1
    );

    for record in (select ds_column.* from ds_column where ds_column.table_name = tablename and existsreal=1 ) do
        if not exists(select column_name from ds_column where ds_column.table_name = concat('',tablename,'_hstr') and column_name=record.column_name) then
            -- select record.column_name rec;
            set @cmd = concat('alter table `',tablename,'_hstr` add column `',record.column_name ,'` ',record.column_type,'');
            -- concat('call addFieldIfNotExists("',concat('',tablename,'_hstr'),'","', '`',record.column_name ,'` ","',record.column_type,'")');
            select @cmd;

            PREPARE stmt FROM @cmd;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

        end if;
    end for;


    
    SET @cmd_template = concat('CREATE OR REPLACE TRIGGER `',tablename,'#KEYNAME#` #TRIGGER_ORDER# ON `',tablename,'` FOR EACH ROW
        BEGIN
        DECLARE uu_id varchar(36);
        SET uu_id = ifnull(@useuuid,uuid());

        if ( (@use_hstr_trigger=1) or (@use_hstr_trigger is null) ) THEN

          INSERT INTO `',tablename,'_hstr`
          (
            hstr_sessionuser,
            hstr_action,
            hstr_revision,
            ',@fldColumns,'
          )
           SELECT
            ifnull(@sessionuser,"not set"),
            "#KEYWORD#",
            uu_id,
            ',@fldColumns,'
          FROM
            `',tablename,'`
          WHERE
            ',@where,'
          on duplicate key update hstr_action=values(hstr_action),hstr_revision=values(hstr_revision),hstr_datetime=values(hstr_datetime)
          ;
          END IF;
          END
        ');


    SET @cmd =  replace(@cmd_template,'#KEYNAME#','__ai');
    SET @cmd =  replace(@cmd,'#TRIGGER_ORDER#','after insert');
    SET @cmd =  replace(@cmd,'#KEYWORD#','insert');
    PREPARE stmt FROM @cmd;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @cmd =  replace(@cmd_template,'#KEYNAME#','__au');
    SET @cmd =  replace(@cmd,'#TRIGGER_ORDER#','after update');
    SET @cmd =  replace(@cmd,'#KEYWORD#','update');
    select @cmd;
    PREPARE stmt FROM @cmd;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @cmd =  replace(@cmd_template,'#KEYNAME#','__bd');
    SET @cmd =  replace(@cmd,'#TRIGGER_ORDER#','before delete');
    SET @cmd =  replace(@cmd,'#KEYWORD#','delete');
    SET @cmd =  replace(@cmd,' = NEW.',' = OLD.');
    PREPARE stmt FROM @cmd;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;



    SET @cmd = concat('call create_index(database(),"',tablename,'_hstr","idx_pri_',tablename,'_hstr","',@priColumns,'")');
    PREPARE stmt FROM @cmd;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;


END //

-- call create_or_upgrade_hstr_table('cron_queries') //
-- SOURCE FILE: ./src//dsx_read_order.sql 
DELIMITER //
DROP FUNCTION IF EXISTS dsx_read_order //
CREATE OR REPLACE FUNCTION `dsx_read_order`( request JSON )
RETURNS longtext
DETERMINISTIC
BEGIN 
    

    RETURN (
        select 
            group_concat( concat('`',property,'` ',direction) separator ',' ) X
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
-- SOURCE FILE: ./src//dsx_rest_api_get.sql 
delimiter //

CREATE OR REPLACE PROCEDURE `dsx_filter_proc`( IN request JSON , OUT result LONGTEXT)
BEGIN 
    DECLARE filterObject JSON;

    DECLARE concat_by varchar(20);
    SET request = JSON_QUERY(request,'$');
    IF JSON_VALUE(request,'$.concat_by') is null THEN set request=JSON_SET(request,'$.concat_by','and'); END IF;
    SET concat_by = concat(' ',JSON_VALUE(request,'$.concat_by' ),' ');


    SET filterObject = JSON_EXTRACT(request,concat('$.','filter'));
    IF JSON_TYPE(filterObject)<>'ARRAY' THEN
      SET filterObject = JSON_VALUE(request,concat('$.','filter'));
    END IF;
--    select request;


    select
                    REGEXP_REPLACE(property,concat('^',JSON_VALUE(request,'$.tablename'),'__'),'') `property`,
                    `operator`,
                    `value`
                from

                    JSON_TABLE( filterObject , '$[*]'  COLUMNS (

                        `property` varchar(128) path '$.property',
                        `operator` varchar(15) path '$.operator',
                        `value`    JSON path '$.value'
                        
                    ) 
                ) as jtx
                where `value` is not null

union

select
    `property`,
    `operator`,
    group_concat(quote(`value`) separator ',') `value`
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
where `value` is not null
) c group by        
     `property`,
    `operator`        ;

                
    
    -- RETURN (


select 
                
                concat('`',REGEXP_REPLACE(`property`,concat('^',JSON_VALUE(request,'$.tablename'),'__'),''),'`') `property`,
                dsx_filter_operator(`operator`) `operator`,
                JSON_VALID(`value`) v,
                JSON_OBJECT('v',`value`) s,
                `value` -- dsx_filter_values_extract(`value`,ds_column.data_type) `value`
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
                        `value`    LONGTEXT path '$.value'
                        
                    ) 
                ) as jtx
                where `property` is not null
            ) jt

            join ds_column 
                on (ds_column.column_name =   jt.property )
             and ds_column.table_name =json_value(request,'$.tablename')

;

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
            ) ftrX
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
                        `value`    varchar(128) path '$.value'
                        
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

                    JSON_TABLE(filterObject, '$[*]'  COLUMNS (

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

        ) FILTER_TABLE

    -- )
    ;
    
END //

CREATE OR REPLACE PROCEDURE `dsx_rest_api_get`( IN request JSON , OUT result JSON)
BEGIN 
    DECLARE userequest JSON;
    DECLARE fieldobjectlist LONGTEXT default '';
    DECLARE idfield LONGTEXT default '';
    DECLARE displayfield LONGTEXT default '';
    DECLARE readtable LONGTEXT default '';
    DECLARE searchany LONGTEXT default '';
    DECLARE searchfield LONGTEXT default '';
    -- DECLARE rownumber LONGTEXT default '';
    DECLARE sorts LONGTEXT default '';
    DECLARE wherefilter LONGTEXT default '';
    DECLARE havingfilter LONGTEXT default '';
    DECLARE basequery LONGTEXT default '';
    DECLARE query LONGTEXT default '';
    DECLARE comibedfieldname integer default 0;
    DECLARE counts integer default 0;
    DECLARE sql_command longtext;

    SET SESSION group_concat_max_len = 4294967295;
    SET userequest = JSON_QUERY(request,'$');

    set result=JSON_OBJECT(
        'data', null,
        'success', false,
        'msg', '-', 
        'total',    null
    );
    SET userequest = JSON_INSERT( userequest, '$.replaced', 1);
    SET sorts =  dsx_read_order(userequest);

    SET @filter = JSON_EXTRACT( userequest, '$.filter'  );
   
    if not exists (select table_name from ds_access where table_name=JSON_VALUE(userequest,'$.tablename') and `read`=1) then
        set @msg=concat('Sie haben kein Leserecht für `',JSON_VALUE(userequest,'$.tablename'),'`.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = @msg, MYSQL_ERRNO = 1001;
    end if;

    SELECT concat( getDSKeySQL(ds.table_name) ,' '), concat('`',ds.displayfield,'` '), if( ifnull(ds.read_table,'')='',ds.table_name,ds.read_table ),ds.searchany 
    INTO idfield,displayfield,readtable,searchany FROM ds WHERE  ds.table_name = JSON_VALUE(userequest,'$.tablename');


    IF JSON_EXTRACT( userequest, '$.filter'  ) is null THEN SET userequest = JSON_SET( userequest, '$.filter', JSON_MERGE( '[]', JSON_ARRAY() ) ); END IF;
    IF JSON_EXTRACT( userequest, '$.latefilter'  ) is null THEN SET userequest = JSON_SET( userequest, '$.latefilter', JSON_MERGE( '[]', JSON_ARRAY() ) ); END IF;

    IF JSON_EXISTS( userequest, '$.latefilter'  ) = 0 THEN SET userequest = JSON_SET( userequest, '$.latefilter', JSON_ARRAY() ); END IF;
    IF JSON_EXISTS( userequest, '$.filter'  ) = 0 THEN SET userequest = JSON_SET( userequest, '$.filter', JSON_ARRAY() ); END IF;

IF JSON_VALUE(userequest,'$.query') IS NOT NULL THEN
    SET userequest = JSON_SET( userequest, '$.search', concat('%',JSON_VALUE(userequest,'$.query'),'%') );
    SET userequest = JSON_SET( userequest, '$.filter_by_search', 1 );
    
END IF;

    IF JSON_VALUE(userequest,'$.search') IS NOT NULL THEN
        SELECT
            ds.searchfield
        INTO 
            searchfield
        FROM 
            ds
        WHERE 
            table_name = JSON_VALUE(userequest,'$.tablename')
        ;

        if (searchfield is null or searchfield='') THEN
            set @msg=concat('Es ist kein Suchfeld für `',JSON_VALUE(userequest,'$.tablename'),'` angelegt');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = @msg, MYSQL_ERRNO = 1001;
        END IF;

        select searchfield;
        IF JSON_VALUE(userequest,'$.filter_by_search')=1 THEN
            SET @filter = JSON_EXTRACT( userequest, '$.filter'  );
            SET @newfilter = JSON_OBJECT();
            SET @newfilter = JSON_SET(@newfilter, '$.operator',  'like');
            SET @newfilter = JSON_SET(@newfilter, '$.property',  searchfield);
            SET @newfilter = JSON_SET(@newfilter, '$.value', concat(if(searchany=1,'%',''),JSON_VALUE(userequest,'$.search'),if(searchany=1,'%','') ) ) ; 
            set @filter = JSON_ARRAY_INSERT(JSON_QUERY(@filter,'$'), '$[0]', JSON_QUERY(@newfilter,'$'));
            SET userequest = JSON_SET( userequest, '$.filter',  @filter );
        ELSE
        
            SET @filter = JSON_EXTRACT( userequest, '$.latefilter'  );
            SET userequest = JSON_SET( userequest, '$.latefilter', 
            JSON_ARRAY_APPEND(@filter, '$', 
                JSON_OBJECT('operator','like','value',  concat(if(searchany=1,'%',''),JSON_VALUE(userequest,'$.search') )  ,'property',searchfield)
            ));
            
        END IF;
    END IF;

    -- select 'userequest',JSON_TYPE(userequest);
    call dsx_filter_proc(userequest,@e);
    SET wherefilter = dsx_filter_values(userequest ,'filter' );
 
 
    IF (wherefilter IS NULL) THEN   
        IF JSON_EXISTS(userequest,'$.extendedwhere') = 1 THEN
            SET wherefilter=JSON_VALUE(userequest,'$.extendedwhere'); 
        ELSE
            SET wherefilter='true';
        END IF;
        
    END IF;
    SET havingfilter = dsx_filter_values(userequest ,'latefilter');
    IF (havingfilter IS NULL) THEN SET havingfilter='true'; END IF;


    SET basequery = concat(
        'SELECT ',
       doublequote(JSON_VALUE(userequest,'$.tablename')),' __table_name,' ,
       idfield,' __id,',
       displayfield,' __displayfield,',
         ' `',JSON_VALUE(userequest,'$.tablename'),'`.* ',
        'FROM `',readtable,'` `',JSON_VALUE(userequest,'$.tablename'),'` ',
        if(wherefilter<>'',concat('WHERE ',wherefilter,' '),''),
        

        if( sorts is null ,'',concat(' ORDER  BY ',sorts))
    );

    set query = basequery;
    IF JSON_VALUE(userequest,'$.debug_query') IS NOT NULL and JSON_VALUE(userequest,'$.debug_query')=1 THEN
     SET result =JSON_SET(result,'$.debug_query',query);
    END IF;


    IF JSON_VALUE(userequest,'$.limit') IS NOT NULL THEN
        IF JSON_VALUE(userequest,'$.start') IS NULL THEN

            IF JSON_VALUE(userequest,'$.page') IS NOT NULL THEN
                set userequest = JSON_SET(userequest,'$.start', (JSON_VALUE(userequest,'$.page')-1) * JSON_VALUE(userequest,'$.limit') ) ;
            END IF;
        
        END IF;
    END IF;

    set @limit_term = '';
    IF JSON_VALUE(userequest,'$.start') IS NOT NULL AND JSON_VALUE(userequest,'$.limit') IS NOT NULL THEN
        set @limit_term = concat(
                ' LIMIT ',JSON_VALUE(userequest,'$.start'),', ',JSON_VALUE(userequest,'$.limit')
        );
    END IF;

    IF JSON_VALUE(userequest,'$.nodata') = 1 THEN
        SET query = concat('',basequery, if(havingfilter<>'','',/*@limit_term**/'' ) );
    ELSE
        SET query = concat('',basequery, if(havingfilter<>'','',@limit_term ) );
    END IF;

    IF JSON_VALUE(userequest,'$.comibedfieldname') IS NOT NULL THEN
        SET comibedfieldname=JSON_VALUE(userequest,'$.comibedfieldname');
    END IF;

    IF JSON_VALUE(userequest,'$.start') IS NULL THEN
        set userequest = JSON_SET(userequest,'$.start',0);
    END IF;
        
    select 
    concat('JSON_OBJECT(
        "__table_name", ',doublequote(JSON_VALUE(userequest,'$.tablename')),' ,
        "__id", ',idfield,' ,
        "__displayfield",',displayfield,' ,',

        if ( JSON_VALUE(userequest,'$.rownumber') IS NOT NULL and JSON_VALUE(userequest,'$.rownumber')=1, concat(
            '"__rownumber", ROW_NUMBER() OVER ( ',if( sorts is null ,'',concat(' ORDER  BY ',sorts)),') + ',JSON_VALUE(userequest,'$.start'),', '
        ),'' ),

        ifnull( group_concat( concat(
            doublequote(
                if(comibedfieldname=1,concat('',JSON_VALUE(userequest,'$.tablename'),'__',ds_column.column_name,''),ds_column.column_name)
            ),',',column_name
        ) separator ', '
        ),concat( '"_nofields_", 1'  )
        
        ),
    ')') 
    into @row
    from 
        ds_column 
        left join ds_db_types_fieldtype on ds_db_types_fieldtype.dbtype = ds_column.data_type 

    where 
        table_name = readtable -- JSON_VALUE(userequest,'$.tablename') 
        and existsreal=1
        and 
        if(JSON_EXTRACT(userequest,'$.returnfields') is not null,
            JSON_SEARCH(JSON_EXTRACT(userequest,'$.returnfields'), 'one', column_name)!="NULL"  -- is not null
        ,true)
    ;


    IF JSON_VALUE(userequest,'$.nodata') = 1 THEN
        SET result =JSON_SET(result,'$.limitterm',@limit_term);

        SET result =JSON_SET(result,'$.query',
            concat(
                'select * from ( ',query,' ) y ',
                if(havingfilter<>'',concat('HAVING ',havingfilter,' '),'')
            )
        );
    ELSE

        set @result_query = concat( 'select JSON_ARRAYAGG(s) into @data from (
            select * from ( select ',@row,' s,y.* from ( ',query,' ) y  ) x ', 
                if(havingfilter<>'',concat('HAVING ',havingfilter,' ',@limit_term)
            ,'') ,' ) z  '  );
        PREPARE stmt FROM @result_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SET result =JSON_SET(result,'$.data',JSON_MERGE('[]',@data));
        IF JSON_VALUE(userequest,'$.count') = 1 THEN
            SET sql_command=concat('select count(0) into @counts from (',basequery,') x');
            PREPARE stmt FROM sql_command;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SET result =JSON_SET(result,'$.total',@counts);
        END IF;


    END IF;

    SET result =JSON_SET(result,'$.order_by',if( sorts is null ,'',concat(' ORDER  BY ',sorts)));
    

    SET result =JSON_SET(result,'$.success',true);
    
END //

-- SOURCE FILE: ./src//dsx_rest_api_set.sql 


DELIMITER //


CREATE OR REPLACE FUNCTION `dsx_rest_api_unescape`(data longtext) RETURNS longtext
    DETERMINISTIC
BEGIN 
    set data = REPLACE(data,concat(char(92),'"'),'"');
    set data = REPLACE(data,concat(char(92),'f'),char(12));
    set data = REPLACE(data,concat(char(92),'n'),char(10));
    set data = REPLACE(data,concat(char(92),'t'),char(9));
    set data = REPLACE(data,concat(char(92),'t'),char(13));
    return data;    
END //

CREATE OR REPLACE PROCEDURE `dsx_rest_api_set`( IN  request JSON , OUT  result JSON)
`whole_proc`:
BEGIN 
    DECLARE use_table_name varchar(128);
    DECLARE msg varchar(255);
    DECLARE use_fields LONGTEXT;
    DECLARE update_fields LONGTEXT;
    DECLARE update_statement_fields LONGTEXT;
    DECLARE use_columns LONGTEXT;
    DECLARE sql_command LONGTEXT;
    DECLARE i integer;
    DECLARE l integer;
    IF (JSON_EXISTS(request,'$.tablename')=0) THEN 
        SET msg = 'tablename not found';
        SET result = JSON_OBJECT('error',msg,'success',0);
        LEAVE whole_proc;
    END IF;

    IF (JSON_EXISTS(request,'$.type')=0) THEN 
        SET msg = 'type not found';
        SET result = JSON_OBJECT('error',msg,'success',0);
        LEAVE whole_proc;
    END IF;

    if (@log_dsx_commands=1) THEN
        drop table if exists test_ds_request;
        create table test_ds_request as select request;
    END IF;

    IF 
        (JSON_VALUE(request,'$.type')='update') 
        and 
        JSON_EXISTS(request,'$.useInsertUpdate')=1
        -- and 
        -- JSON_VALUE(request,'$.useInsertUpdate')=true
    THEN 

        SET request=JSON_SET(request,'$.type','insert');
        SET request=JSON_SET(request,'$.update',true);
    END IF;
    

    IF (
        JSON_VALUE(request,'$.type')='update'
        or JSON_EXISTS(request,'$.useInsertUpdate')=1
    ) THEN 
        if not exists (select table_name from ds_access where `role` in (select `group` from view_session_groups) and  table_name=JSON_VALUE(request,'$.tablename') and `write`=1) then
            set @msg=concat('Sie haben kein Recht zum Ändern für `',JSON_VALUE(request,'$.tablename'),'`.');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = @msg, MYSQL_ERRNO = 1001;
        end if;
    END IF;

    IF (JSON_VALUE(request,'$.type')='delete') THEN 
        if not exists (select table_name from ds_access where `role` in (select `group` from view_session_groups) and  table_name=JSON_VALUE(request,'$.tablename') and `delete`=1) then
            set @msg=concat('Sie haben kein Recht zum Löschen für `',JSON_VALUE(request,'$.tablename'),'`.');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = @msg, MYSQL_ERRNO = 1001;
        end if;
    END IF;

    IF ( 
        (JSON_VALUE(request,'$.type')='insert' or JSON_VALUE(request,'$.type')='replace' )
        and JSON_EXISTS(request,'$.useInsertUpdate')=0
    ) 
    THEN 
        if not exists (select table_name from ds_access where `role` in (select `group` from view_session_groups) and  table_name=JSON_VALUE(request,'$.tablename') and `append`=1) then
            set @msg=concat('Sie haben kein Recht zum Anfügen für `',JSON_VALUE(request,'$.tablename'),'`.');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = @msg, MYSQL_ERRNO = 1001;
        end if;
    END IF;


    IF (JSON_EXISTS(request,'$.ignore')=0) THEN 
        SET request = JSON_SET(request,'$.ignore',0);
    END IF;
    IF (JSON_EXISTS(request,'$.replace')=0) THEN 
        SET request = JSON_SET(request,'$.replace',0);
    END IF;
    IF (JSON_EXISTS(request,'$.update')=0) THEN 
        SET request = JSON_SET(request,'$.update',0);
    END IF;

    -- teste ob die Tabelle existiert
    select JSON_TYPE(JSON_EXTRACT(request,'$.data')) into @json_table_type;
    select JSON_TYPE(request ) into @json_request_type;


    IF JSON_TYPE(JSON_EXTRACT(request,'$.data'))='ARRAY' THEN 
        SET use_table_name = JSON_VALUE(request,'$.tablename');
        IF use_table_name is not null THEN 
            -- select JSON_EXTRACT(request,'$.data');

            select 
                group_concat(
                    concat('`',column_name,'`')
                    order by column_name
                    separator ','
                ) c,
                group_concat(
                    concat('`',column_name,'` ',column_type,' path "$.', column_name,'" ',/*if( is_nullable='YES','NULL','ERROR')*/'NULL' ,' ON EMPTY ')
                    order by column_name
                    separator ','
                ) x,
                group_concat(
                    concat('`',column_name,'`=values(`',column_name,'`)')
                    order by column_name
                    separator ','
                ) update_fields
            into 
                use_fields,
                use_columns,
                update_fields
            from 
                ds_column
            where 
                ds_column.table_name = use_table_name
                and ds_column.existsreal=1
                and ds_column.writeable =1
                and column_type <> ''
            ;

            drop table if exists temp_dsx_rest_data;
            set sql_command = concat( 
                'create temporary table `temp_dsx_rest_data` as ',
                'select _rownumber,`__id`,',
                
                '`__file_data`,`__file_name`,`__file_id`,`__file_type`',

                ',',use_fields,' ',
                'from json_table(?, "$.data[*]" columns(_rownumber for ordinality, ',
                
                '`__id` varchar(255) path "$.__id", ',

                '`__file_data` longtext path "$.__file_data", ',
                '`__file_name` varchar(255) path "$.__file_name", ',
                '`__file_id` varchar(36) path "$.__file_id", ',
                '`__file_type` varchar(255) path "$.__file_type", ',
                
                ' ',use_columns,')) as jt');
            if (@log_dsx_commands=1) THEN
                drop table if exists test_ds_cmd;
                create table test_ds_cmd as select sql_command;
            END IF;


            PREPARE stmt FROM sql_command;
            EXECUTE stmt USING request;
            DEALLOCATE PREPARE stmt;

            -- select sql_command;
            -- select temp_dsx_rest_data.* from temp_dsx_rest_data;

            FOR record IN (
                select 
                    concat(
                        'update temp_dsx_rest_data set `',
                        column_name,
                        '`= dsx_rest_api_unescape(`',column_name,'`)'
                    ) s
                from 
                    ds_column
                where 
                    ds_column.table_name = use_table_name
                    and ds_column.existsreal=1
                    and ds_column.writeable =1
                    and ds_column.data_type in ('char','longtext','varchar')
                    and ds_column.column_type <> ''
            ) DO

                if (@log_dsx_commands=1) THEN
                    drop table if exists test_ds_cmd;
                    create table test_ds_cmd as select record.s;
                END IF;
                PREPARE stmt FROM record.s;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END FOR;

            -- select temp_dsx_rest_data.* from temp_dsx_rest_data;

            if JSON_VALUE(request,'$.type')<>'delete' then
                FOR record IN (
                        select
                            concat('update temp_dsx_rest_data set `',
                                    column_name,'`=',SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3),
                                ' where `',column_name,'` is null ',
                                if(ds_column.data_type in ('char','longtext','varchar'),concat(' or `',column_name,'`="" '),'')
                            ) s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and ( SUBSTRING(ds_column.default_value,1,2)='{:' and SUBSTRING(ds_column.default_value,length(ds_column.default_value),1)='}')  
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                    union 

                        select
                            concat('update temp_dsx_rest_data set `',column_name,'`=now() where `',column_name,'` is null  ') s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and default_value='{DATETIME}'
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                    union 
                        select
                            concat('update temp_dsx_rest_data set `',column_name,'`=curdate() where `',column_name,'` is null   ') s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and default_value='{DATE}'
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                    union 
                        select
                            concat('update temp_dsx_rest_data set `',column_name,'`=curtime() where `',column_name,'` is null   ') s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and default_value='{TIME}'
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                    union 
                        select
                            concat('update temp_dsx_rest_data set `',column_name,'`=uuid() where `',column_name,'` is null or `',column_name,'`="" ') s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and default_value='{GUID}'
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                    

                ) DO

                    set sql_command = record.s;
                    if (@log_dsx_commands=1) THEN
                        drop table if exists test_ds_cmd;
                        create table test_ds_cmd as select sql_command;
                    END IF;
                    PREPARE stmt FROM sql_command;
                    EXECUTE stmt;
                    DEALLOCATE PREPARE stmt;
                END FOR;
                FOR record IN (
                        select
                            concat('update temp_dsx_rest_data set `',column_name,'`= @serial + _rownumber where  `',column_name,'` is null  ') s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and ds_column.default_value='{#serial}' 
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                ) DO
                    

                    set sql_command = concat('select ifnull( max(`',record.column_name,'`) , 0) m into @serial from `',use_table_name,'`');

                    if (@log_dsx_commands=1) THEN
                        drop table if exists test_ds_cmd;
                        create table test_ds_cmd as select sql_command;
                    END IF;

                    PREPARE stmt FROM sql_command;
                    EXECUTE stmt;
                    DEALLOCATE PREPARE stmt;


                    set sql_command = record.s;
                    PREPARE stmt FROM sql_command;
                    EXECUTE stmt;
                    DEALLOCATE PREPARE stmt;
                    
                END FOR;

                FOR record IN (
                        select
                            concat('update temp_dsx_rest_data set `',column_name,'`= ',quote(ds_column.default_value),' where  `',column_name,'` is null  ') s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and ds_column.default_value<>'' 
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                ) DO

                    set sql_command = record.s;
                    if (@log_dsx_commands=1) THEN
                        drop table if exists test_ds_cmd;
                        create table test_ds_cmd as select sql_command;
                    END IF;

                    PREPARE stmt FROM sql_command;
                    EXECUTE stmt;
                    DEALLOCATE PREPARE stmt;
                    
                END FOR;

            END IF;
            /*
            set sql_command = concat('
                insert into `',use_table_name,'` (',use_fields,') select ',use_fields,' from temp_dsx_rest_data
                on duplicate key update 
                    ',update_fields,'            ');
            */


            IF JSON_VALUE(request,'$.type')='update' THEN

                select
                    group_concat( concat('`',use_table_name,'`.`',column_name,'` = temp_dsx_rest_data.`',column_name,'`') separator ',') s
                into 
                    update_statement_fields
                from
                    ds_column
                where 
                    ds_column.table_name = use_table_name
                    and ds_column.existsreal=1
                    and ds_column.writeable =1
                    and ds_column.column_type <> ''
                    and JSON_EXISTS(request,concat('$.data[0].', column_name))=1
                ;
                

                set sql_command = concat(
                         'insert ignore into ',
                        '`',use_table_name,'` (',use_fields,') select ',use_fields,' from temp_dsx_rest_data',
                        '            ');
                PREPARE stmt FROM sql_command;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;

                set sql_command = concat('
                    update `',use_table_name,'` 
                    join temp_dsx_rest_data on 
                        (',dsx_get_key_sql_prefix(use_table_name,use_table_name),') =
                        (', 'temp_dsx_rest_data.__id',')
                    set ',update_statement_fields,'
                ');
                select sql_command;

            ELSEIF
                JSON_VALUE(request,'$.type')='delete' THEN
                set sql_command = concat('
                    delete from `',use_table_name,'` where ',dsx_get_key_sql( use_table_name),' in (select __id from temp_dsx_rest_data)');
                
                select 
                 concat('
                    delete from `',use_table_name,'` where ( ',
                        group_concat( 
                            concat('ifnull(',if(
                                concat( ds_column.column_name)='__id',
                                dsx_get_key_sql( use_table_name),
                                concat('`',ds_column.column_name,'`')
                            ),',"I AM NULL")') separator ','
                        )  ,
                    ' ) in (select ',
                        group_concat( 
                            concat('ifnull(',if(
                                concat( ds_column.column_name)='__id',
                                '__id',
                                concat('`',ds_column.column_name,'`')
                            ),',"I AM NULL")') separator ','
                    )  ,' from temp_dsx_rest_data) '
                )
                    
                into sql_command
                from json_table(
                    json_keys(json_extract(request,concat('$.data[0]'))) 
                    , '$[*]' columns (x varchar(255) path '$')) x
                    join (
                            select  
                                table_name, column_name 
                            from ds_column 
                            where 
                                ds_column.existsreal=1
                            and ds_column.table_name = use_table_name
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                        union 
                            select '' table_name, 'id' column_name 
                        ) ds_column 
                    on   ( concat( ds_column.column_name) = x.x)
                    ;
                -- select ifnull(`xfield`,"I AM NULL") from temp_dsx_rest_data;
                -- select `xfield` from temp_dsx_rest_data;
                -- select * from `test` where `xfield` in (select `xfield` from temp_dsx_rest_data) ;
                
                IF sql_command is null THEN
                 SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'no fields match for deletion', MYSQL_ERRNO = 1000;
                 LEAVE whole_proc;
                END IF;
                
            ELSEIF
                JSON_VALUE(request,'$.type')='insert' THEN

                if JSON_VALUE(request,'$.replace')='1' THEN
                    set sql_command = concat('
                        replace into `',use_table_name,'` (',use_fields,') select ',use_fields,' from temp_dsx_rest_data
                        ');
                ELSE
                    set sql_command = concat(
                        if (
                            JSON_VALUE(request,'$.replace')='1',
                            'replace into ',
                            if (
                                JSON_VALUE(request,'$.ignore')='1',
                                'insert ignore into ',
                                'insert into '
                            )
                        ),
                        
                        '`',use_table_name,'` (',use_fields,') select ',use_fields,' from temp_dsx_rest_data',
                        
                        if (
                            JSON_VALUE(request,'$.update')='1',
                            concat(' on duplicate key update ',update_fields,''),
                            ''
                        ),
                        '            ');

                END IF;
                
                
            END IF;

            if (@log_dsx_commands=1) THEN
                drop table if exists test_ds_cmd;
                create table test_ds_cmd as select sql_command;
            END IF;


            PREPARE stmt FROM sql_command;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            

            alter table temp_dsx_rest_data add __clientId text;
            set sql_command = concat('update temp_dsx_rest_data set __clientid = __id');
            PREPARE stmt FROM sql_command;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;


            set sql_command = concat('update temp_dsx_rest_data set __id = ',dsx_get_key_sql( use_table_name ));
            PREPARE stmt FROM sql_command;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;


/*
            select 
                concat('JSON_OBJECT( "__table_name", ',doublequote(JSON_VALUE(request,'$.tablename')),
                    ' ,  "__newid", ',dsx_get_key_sql( use_table_name ),'',
                    ' ,  "__id", __id',
                    ' , "__displayfield",',displayfield,' ,',
                    ifnull( group_concat( concat(
                        doublequote(
                            if(JSON_VALUE(request,'$.comibedfieldname')=1,concat('', ds_column.column_name,''),ds_column.column_name)
                        ),',`',column_name,'`'
                    ) separator ', '
                    ),concat( '"_nofields_", 1'  )
                    
                    ),
                ')') 
                into @row
                from 
                    ds_column 
                    join ds on ds_column.table_name = ds.table_name
                    left join ds_db_types_fieldtype on ds_db_types_fieldtype.dbtype = ds_column.data_type 

                where 
                    ds_column.table_name =  JSON_VALUE(request,'$.tablename') 
                    and ds_column.existsreal=1
                    and 
                    if(JSON_EXTRACT(request,'$.returnfields') is not null,
                        JSON_SEARCH(JSON_EXTRACT(request,'$.returnfields'), 'one', column_name)!="NULL"  -- is not null
                    ,true)
                ;
*/
            SET result = JSON_OBJECT('success',1,'message','OK');

            if JSON_VALUE(request,'$.type')<>'delete' then

                if JSON_EXISTS(request,'$.data[0].__file_data') and JSON_EXISTS(request,'$.data[0].__file_name') then
                    
                    for rec in (
                        select 
                            __id,
                            __file_data,
                            __file_name,
                            if(ifnull(__file_id,'')='',uuid(),__file_id) __file_id,
                            __file_type
                        from 
                            temp_dsx_rest_data 
                        where __file_data is not null
                    ) do
                    
                        insert into ds_files    
                        (
                            file_id,
                            table_name,
                            name,
                            path,
                            size,
                            mtime,
                            ctime,
                            type,
                            hash,
                            login
                        ) values
                        (
                            rec.__file_id,
                            use_table_name,
                            rec.__file_name,
                            concat('files/',rec.__file_id),
                            length(rec.__file_data),
                            now(),
                            now(),
                            rec.__file_type,
                            md5(rec.__file_data),
                            @sessionuser
                        ) on duplicate key update
                            mtime=now(),
                            size=length(rec.__file_data),
                            hash=md5(rec.__file_data),
                            login=@sessionuser;
                        
                        insert into ds_files_data
                        (
                            file_id,
                            data
                        ) values
                        (
                            rec.__file_id,
                            rec.__file_data
                        ) on duplicate key update
                            data=rec.__file_data;

                        set sql_command = concat('
                            update `',use_table_name,'` 
                            set file_id=',quote(rec.__file_id),'  
                            where ',dsx_get_key_sql( use_table_name),' in (select ',dsx_get_key_sql_prefix('temp_dsx_rest_data',use_table_name),' from temp_dsx_rest_data where __id=',quote(rec.__id),')');
                        PREPARE stmt FROM sql_command;
                        EXECUTE stmt;
                        DEALLOCATE PREPARE stmt;

                        call ds_files_cleanup(use_table_name);
                    end for;


                end if;
                
            end if;


        ELSE

            SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'Tablename not given', MYSQL_ERRNO = 1000;

        END IF;

    ELSE

        SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'Not an array', MYSQL_ERRNO = 1000;

    END IF;

END //




