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

    SELECT concat( dsx_get_key_sql_prefix(JSON_VALUE(userequest,'$.tablename'),ds.table_name) ,' '), concat('`',JSON_VALUE(userequest,'$.tablename'),'`.','`',ds.displayfield,'` '), if( ifnull(ds.read_table,'')='',ds.table_name,ds.read_table ),ds.searchany 
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
       '',displayfield,' __displayfield,',

if(
    JSON_EXISTS(userequest,'$.concat_set_table') = 1,
    '__clientid, ',
    ''
),

         ' `',JSON_VALUE(userequest,'$.tablename'),'`.* ',
        'FROM `',readtable,'` `',JSON_VALUE(userequest,'$.tablename'),'` ',

        if(
            JSON_EXISTS(userequest,'$.concat_set_table') = 1,
            concat(
                ' join temp_dsx_rest_data on ',
                dsx_get_key_sql_prefix('temp_dsx_rest_data',JSON_VALUE(userequest,'$.tablename')),'=',
                dsx_get_key_sql_prefix(JSON_VALUE(userequest,'$.tablename'),JSON_VALUE(userequest,'$.tablename'))
            ),
            ''
        ),

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
