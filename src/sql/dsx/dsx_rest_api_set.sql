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
    DECLARE ref_sql_command LONGTEXT;
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

        select 
            if(ifnull(writetable,'') = '',use_table_name,writetable) 
            into use_table_name
        from ds where table_name = use_table_name;

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
                and ds_column.is_generated <> 'ALWAYS'
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


            IF (JSON_EXISTS(request,'$.update')=1) THEN
                FOR record IN (
                    select
                        concat(
                            'update temp_dsx_rest_data,`',use_table_name,'` set temp_dsx_rest_data.`',column_name,'`= `',use_table_name,'`.`',column_name,'` ',
                            ' where temp_dsx_rest_data.`',column_name,'` is null ',
                            'and ',dsx_get_key_sql_prefix(use_table_name,use_table_name),' = temp_dsx_rest_data.__id'
                        ) s
                    from 
                        ds_column
                    where 
                        ds_column.table_name = use_table_name
                        and ds_column.existsreal=1
                        and ds_column.writeable =1
                        and ds_column.is_generated <> 'ALWAYS'
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
            END IF;


                if (@log_dsx_commands=1) THEN
                    drop table if exists test_ds_cmd;
                    create table test_ds_cmd as select '208' s;
                END IF;

            FOR record IN (
                select
                    concat(
                        'update temp_dsx_rest_data,`',use_table_name,'` set temp_dsx_rest_data.`',column_name,'`= @serial + _rownumber ',
                        ' where (temp_dsx_rest_data.`',column_name,'` is null ) ',
                        ' and ',dsx_get_key_sql_prefix(use_table_name,use_table_name),'= temp_dsx_rest_data.__id'
                    ) s
                from 
                    ds_column
                where 
                    ds_column.table_name = use_table_name
                    and ds_column.default_value='{#serial}' 
                    and ds_column.existsreal=1
                    and ds_column.writeable =1
                    and ds_column.is_generated <> 'ALWAYS'
                    and ds_column.column_type <> ''
                           
                ) DO

                                PREPARE stmt FROM record.s;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END FOR;
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
                    and ds_column.is_generated <> 'ALWAYS'
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
                            and ds_column.is_generated <> 'ALWAYS'
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
                            and ds_column.is_generated <> 'ALWAYS'
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
                            and ds_column.is_generated <> 'ALWAYS'
                            and ds_column.column_type <> ''
                           
                    /*
                    union 
                        select
                            concat('update temp_dsx_rest_data set `',column_name,'`=dsx_get_key_sql(',use_table_name,') where `',column_name,'` is null   ') s,
                            column_name,
                            SUBSTRING(ds_column.default_value,3,length(ds_column.default_value)-3) fn,
                            default_value
                        from 
                            ds_column
                        where 
                            ds_column.table_name = use_table_name
                            and default_value='{RIDX}'
                            and ds_column.existsreal=1
                            and ds_column.writeable =1
                            and ds_column.column_type <> ''
                    */
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
                            and ds_column.is_generated <> 'ALWAYS'
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
                            and ds_column.is_generated <> 'ALWAYS'
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
                            concat(
                                'update temp_dsx_rest_data set `',column_name,'`= @serial + _rownumber ',
                                
                                if( 
                                    ( (data_type='int' or data_type='bigint') and ( JSON_VALUE(request,'$.type')='insert')  ),
                                    concat('where  `',column_name,'` < 0 '),
                                    concat('where  `',column_name,'` is null ')
                                )
                            ) s,
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
                            and ds_column.is_generated <> 'ALWAYS'
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
                            and ds_column.is_generated <> 'ALWAYS'
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
                    and ds_column.is_generated <> 'ALWAYS'
                    and ds_column.column_type <> ''
                    and JSON_EXISTS(request,concat('$.data[0].', column_name))=1
                   
                ;
                
                /*
                set sql_command = concat(
                         'insert ignore into ',
                        '`',use_table_name,'` (',use_fields,') select ',use_fields,' from temp_dsx_rest_data',
                        '            ');
                PREPARE stmt FROM sql_command;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
                */

                set sql_command = concat('
                    update `',use_table_name,'` 
                    join temp_dsx_rest_data on 
                        (',dsx_get_key_sql_prefix(use_table_name,use_table_name),') =
                        (', 'temp_dsx_rest_data.__id',')
                    set ',update_statement_fields,'
                ');
                



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
                            and ds_column.is_generated <> 'ALWAYS'
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


            if (JSON_VALUE(request,'$.check_foreign_key')=1) THEN
                FOR ref in (
                    SELECT 
                        TABLE_NAME,
                        CONSTRAINT_NAME,
                        REFERENCED_TABLE_NAME,
                            group_concat( concat('`',COLUMN_NAME,'`') separator ',') COLUMN_NAMES,
                            group_concat( concat('`',REFERENCED_COLUMN_NAME,'`') separator ',') REFERENCED_COLUMN_NAMES,

                             count(*) c
                    FROM
                        INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                    WHERE
                        REFERENCED_TABLE_SCHEMA = database()  
                        AND TABLE_NAME = use_table_name
                    group by CONSTRAINT_NAME
                ) DO 

                    set @error_row = null;
                    set ref_sql_command = concat('select min(_rownumber) into @error_row from temp_dsx_rest_data where (',ref.COLUMN_NAMES,') not in (select ',ref.REFERENCED_COLUMN_NAMES,' from `',ref.REFERENCED_TABLE_NAME,'`)');
                    if (ref_sql_command is not null) then
                        PREPARE stmt FROM ref_sql_command;
                        EXECUTE stmt;
                        DEALLOCATE PREPARE stmt;
                        if @error_row is not null then
                            set @msg = concat('Referenzfehler in Zeile ',@error_row,' für ',ref.COLUMN_NAMES,' in ',ref.REFERENCED_TABLE_NAME, '(',ref.REFERENCED_COLUMN_NAMES,')');
                            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg, MYSQL_ERRNO = 1000;
                            LEAVE whole_proc;
                        end if;
                    end if;

                END FOR;
            end if;


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

                        if length(rec.__file_data) <> 0 then
                        
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
                        end if;
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



