delimiter //

SET NAMES 'utf8mb4' COLLATE 'utf8mb4_general_ci' //

CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_checks`( IN  request JSON )
BEGIN 
    DECLARE msg varchar(255);


    IF (JSON_VALID(request)=0) THEN 
        SET msg = 'input json invalid';

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;

    END IF;
    IF (JSON_EXISTS(request,'$.tablename')=0) THEN 
        SET msg = 'attribute tablename not found';

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;

    END IF;
    IF (JSON_EXISTS(request,'$.type')=0) THEN 
        SET msg = 'attribute type not found';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
    END IF;
    IF (JSON_EXISTS(request,'$.data')=0) THEN 
        SET msg = 'attribute data not found';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
    END IF;


    IF JSON_TYPE(JSON_EXTRACT(request,'$.data'))<>'ARRAY' THEN 
        SET msg = 'attribute data is not an array';
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
    END IF;

    IF (JSON_VALUE(request,'$.type')='update' or JSON_EXISTS(request,'$.useInsertUpdate')=1 ) THEN 
        if not exists (select table_name from ds_access where `role` in (select `group` from view_session_groups) and  table_name=JSON_VALUE(request,'$.tablename') and `write`=1) then
            set msg=concat('Sie haben kein Recht zum Ändern für `',JSON_VALUE(request,'$.tablename'),'`.');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
        end if;
    END IF;

    IF (JSON_VALUE(request,'$.type')='delete') THEN 
        if not exists (select table_name from ds_access where `role` in (select `group` from view_session_groups) and  table_name=JSON_VALUE(request,'$.tablename') and `delete`=1) then
            set msg=concat('Sie haben kein Recht zum Löschen für `',JSON_VALUE(request,'$.tablename'),'`.');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
        end if;
    END IF;

    IF ( 
        (JSON_VALUE(request,'$.type')='insert' or JSON_VALUE(request,'$.type')='replace' )
        and JSON_EXISTS(request,'$.useInsertUpdate')=0
    ) 
    THEN 
        if not exists (select table_name from ds_access where `role` in (select `group` from view_session_groups) and  table_name=JSON_VALUE(request,'$.tablename') and `append`=1) then
            set msg=concat('Sie haben kein Recht zum Anfügen für `',JSON_VALUE(request,'$.tablename'),'`.');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
        end if;
    END IF;


END //

CREATE OR REPLACE FUNCTION `dsx_rest_api_set_operation_defaults`( request JSON ) RETURNS JSON
BEGIN 
    IF (JSON_VALUE(request,'$.type')='update') and  JSON_EXISTS(request,'$.useInsertUpdate')=1 THEN 
        SET request=JSON_SET(request,'$.type','insert');
        SET request=JSON_SET(request,'$.update',true);
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
    RETURN request;
END //   


CREATE OR REPLACE FUNCTION `dsx_rest_api_set_use_table_name`( request JSON ) RETURNS varchar(128)
BEGIN
    DECLARE use_table_name varchar(128);
    DECLARE msg varchar(255);

    SET use_table_name = JSON_VALUE(request,'$.tablename');
    select if(ifnull(writetable,'') = '',use_table_name,writetable)  into use_table_name from ds where table_name = use_table_name and existsreal=1;
    IF use_table_name is  null THEN  
        set msg=concat('error on (write-) tablename.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
    END IF;
    RETURN use_table_name;
END //   


CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_loop_set_serial`( IN  temp_table_name varchar(128), IN  use_table_name varchar(128) )
BEGIN
    FOR record IN (
        select
            concat(
                'update ',temp_table_name,' temp_alias,`',use_table_name,'` set temp_alias.`',column_name,'`= @serial + _rownumber ',
                ' where (temp_alias.`',column_name,'` is null ) ',
                ' and ',dsx_get_key_sql_prefix(use_table_name,use_table_name),'= temp_alias.__id'
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
END //



CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_loop_set_function`( IN  temp_table_name varchar(128), IN  use_table_name varchar(128) )
BEGIN

    DECLARE sql_command LONGTEXT;
    FOR record IN (
        select
                concat('update ',temp_table_name,' set `',
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
                concat('update ',temp_table_name,' set `',column_name,'`=now() where `',column_name,'` is null  ') s,
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
                concat('update ',temp_table_name,' set `',column_name,'`=curdate() where `',column_name,'` is null   ') s,
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
                
        
        union 
            select
                concat('update ',temp_table_name,' set `',column_name,'`=curtime() where `',column_name,'` is null   ') s,
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
                concat('update ',temp_table_name,' set `',column_name,'`=uuid() where `',column_name,'` is null or `',column_name,'`="" ') s,
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
        PREPARE stmt FROM sql_command;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END FOR;
END //

CREATE OR REPLACE FUNCTION `dsx_rest_api_set_get_update_statement`( IN  temp_table_name varchar(128), IN  use_table_name varchar(128)) returns LONGTEXT
BEGIN

    DECLARE use_template_update_fields LONGTEXT;
    DECLARE sql_command LONGTEXT;
    select
        group_concat( concat('`',use_table_name,'`.`',column_name,'` = ',temp_table_name,'.`',column_name,'`') separator ',') s
    into 
        use_template_update_fields
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

    set sql_command = concat('
        update `',use_table_name,'` 
        join ',@temp_table_name,' temp_alias on 
            (',dsx_get_key_sql_prefix(use_table_name,use_table_name),') =
            (', 'temp_alias.__id',')
        set ',use_template_update_fields,'
    ');
    RETURN sql_command;

END //

CREATE OR REPLACE FUNCTION `dsx_rest_api_set_get_delete_statement`( IN  temp_table_name varchar(128), IN  use_table_name varchar(128)) returns LONGTEXT
BEGIN
    DECLARE sql_command LONGTEXT;
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
            )  ,' from ',@temp_table_name,') '
        )
    into 
        sql_command
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

    IF sql_command is null THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'no fields match for deletion', MYSQL_ERRNO = 1001;
    END IF;
    RETURN sql_command;

END //


CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_handle_filedata`( IN  request JSON, IN  temp_table_name varchar(128), IN  use_table_name varchar(128)) 
BEGIN
    DECLARE sql_command LONGTEXT;
    if JSON_EXISTS(request,'$.data[0].__file_data') and JSON_EXISTS(request,'$.data[0].__file_name') then
        set sql_command = concat('create temporary table temp_dsx_rest_data as select * from ',temp_table_name);
        PREPARE stmt FROM sql_command;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;


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
                    -- ,
                    -- size=length(rec.__file_data),
                    -- hash=md5(rec.__file_data),

                    -- name=rec.__file_name,

                    login=@sessionuser;
                
                
                if length(rec.__file_data) <> 0 then
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

                    update ds_files set size=length(rec.__file_data), hash=md5(rec.__file_data),mtime=now() where file_id=rec.__file_id;
                    
                end if;

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
END //

CREATE OR REPLACE FUNCTION `dsx_rest_api_set_get_insert_statement`( 
    IN subtype varchar(50),
    IN  use_template_fields LONGTEXT, 
    IN  use_template_update_fields LONGTEXT, 
    IN  temp_table_name varchar(128), 
    IN  use_table_name varchar(128)
) returns LONGTEXT
BEGIN
    DECLARE sql_command LONGTEXT;

    set sql_command = concat(
    if (
        subtype='replace',
        'replace into ',
        if (
            subtype='ignore',
            'insert ignore into ',
            'insert into '
        )
    ),
    
    '`',use_table_name,'` (',use_template_fields,') select ',use_template_fields,' from ',temp_table_name,'',
    
    if (
        subtype='update',
        concat(' on duplicate key update ',use_template_update_fields,''),
        ''
    ),
    '            ');
    RETURN sql_command;
END //

CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_use_old_values`(  IN  temp_table_name varchar(128), IN  use_table_name varchar(128)) 
BEGIN
    DECLARE x LONGTEXT;
    FOR record IN (
        select
            concat(
                'update ',temp_table_name,' as `temp_alias`,`',use_table_name,'` set temp_alias.`',column_name,'`= `',use_table_name,'`.`',column_name,'` ',
                ' where temp_alias.`',column_name,'` is null ',
                'and ',dsx_get_key_sql_prefix(use_table_name,use_table_name),' = temp_alias.__id'
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


        PREPARE stmt FROM record.s;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END FOR;


END //



CREATE OR REPLACE PROCEDURE `dsx_rest_api_set_use_old_values_readtable`(  IN  temp_table_name varchar(128), IN  use_table_name varchar(128)) 
BEGIN
    DECLARE x LONGTEXT;
    DECLARE read_table_name varchar(128);

    set read_table_name = (select read_table from ds where table_name =use_table_name and read_table<>'' and read_table is not null);
    if read_table_name is not null then 
        FOR record IN (
            select
                concat(
                    'update ',temp_table_name,' as `temp_alias`,`',read_table_name,'` set temp_alias.`',a.column_name,'`= `',read_table_name,'`.`',a.column_name,'` ',
                    ' where temp_alias.`',a.column_name,'` is null ',
                    'and ',dsx_get_key_sql_prefix(read_table_name,use_table_name),' = temp_alias.__id'
                ) s
            from 
                ds_column a
                join ds_column b
                    on 
                        a.column_name = b.column_name
                        and a.table_name = use_table_name
                        and b.table_name = read_table_name


            where 
                
                a.existsreal=1
                and a.writeable =1
                and a.is_generated <> 'ALWAYS'
                and a.column_type <> ''
        ) DO


            PREPARE stmt FROM record.s;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END FOR;
    end if;


END //


CREATE OR REPLACE PROCEDURE `dsx_rest_api_set`( IN  request JSON , OUT  result JSON)
BEGIN

    DECLARE temp_table_name varchar(128);
    DECLARE use_table_name varchar(128);
    DECLARE subtype varchar(128);
    DECLARE use_template_columns LONGTEXT;
    DECLARE use_template_fields LONGTEXT;
    DECLARE use_template_update_fields LONGTEXT;

    DECLARE update_statement_fields LONGTEXT;
    DECLARE sql_command LONGTEXT;
    DECLARE msg LONGTEXT;

    call dsx_rest_api_set_checks(request);

    -- derzeit unsicher, ob noch benötigt
    -- SET request = fixBackslashBug(request); 

    SET request = dsx_rest_api_set_operation_defaults(request);
    SET use_table_name = dsx_rest_api_set_use_table_name(request);


    select 
        group_concat(
            concat('`',column_name,'`')
            order by column_name
            separator ','
        ) c,
        group_concat(
            concat('`',column_name,'` ',if(INSTR(column_type,'enum')=1,'varchar(255)', column_type),' path "$.', column_name,'" ',/*if( is_nullable='YES','NULL','ERROR')*/'NULL' ,' ON EMPTY ')
            order by column_name
            separator ','
        ) x,
        group_concat(
            concat('`',column_name,'`=values(`',column_name,'`)')
            order by column_name
            separator ','
        ) update_fields
    into 
        use_template_fields,
        use_template_columns,
        use_template_update_fields
    from 
        ds_column
    where 
        ds_column.table_name = use_table_name
        and ds_column.existsreal=1
        and ds_column.writeable =1
        and ds_column.is_generated <> 'ALWAYS'
        and column_type <> ''
    ;
    set temp_table_name = concat('temp_dsx_rest_data',replace(uuid(),'-',''));
set @temp_table_name = temp_table_name;

    set sql_command = concat( 
    'create temporary table `',temp_table_name,'` as ',
    'select 
        _rownumber,
        `__id`,
        `__clientid`,
        `__file_data`,
        `__file_name`,
        `__file_id`,
        `__file_type`',
        ',',use_template_fields,' ',
    'from json_table(?, "$.data[*]" columns(
        _rownumber for ordinality, ',
        '`__clientid` varchar(255) path "$.__id", ',
    '`__id` varchar(255) path "$.__id", ',
        '`__file_data` longtext path "$.__file_data", ',
        '`__file_name` varchar(255) path "$.__file_name", ',
        '`__file_id` varchar(36) path "$.__file_id", ',
        '`__file_type` varchar(255) path "$.__file_type", ',
    
    ' ',use_template_columns,')) as jt');

    PREPARE stmt FROM sql_command;
    EXECUTE stmt USING request;
    DEALLOCATE PREPARE stmt;    

    IF JSON_VALUE(request,'$.type')<>'delete' then
        -- read old values removed
        
        call dsx_rest_api_set_use_old_values(temp_table_name,use_table_name);
        call dsx_rest_api_set_use_old_values_readtable(temp_table_name,use_table_name);
        
        call dsx_rest_api_set_loop_set_serial(temp_table_name,use_table_name);
        -- unescape removed
        call dsx_rest_api_set_loop_set_function(temp_table_name,use_table_name);
    END IF;

    set sql_command=null;
    IF JSON_VALUE(request,'$.type')='update' THEN
        SET sql_command = dsx_rest_api_set_get_update_statement(temp_table_name,use_table_name);
    END IF;
    IF JSON_VALUE(request,'$.type')='delete' THEN
        SET sql_command = dsx_rest_api_set_get_delete_statement(temp_table_name,use_table_name);
    END IF;

    IF JSON_VALUE(request,'$.type')='insert' THEN
        SET subtype = 'insert';
        IF JSON_VALUE(request,'$.replace')='1' THEN 
            set subtype='replace';
        END IF;
        IF JSON_VALUE(request,'$.ignore')='1' THEN 
            set subtype='ignore';
        END IF;
        IF JSON_VALUE(request,'$.update')='1' THEN 
            set subtype='update';
        END IF;
        SET sql_command = dsx_rest_api_set_get_insert_statement(subtype,use_template_fields,use_template_update_fields, temp_table_name,use_table_name);
    END IF;

    -- check_foreign_key not active 

    if sql_command is null THEN
        set msg=concat('generated sql_command is null');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = msg, MYSQL_ERRNO = 1001;
    END IF;


    PREPARE stmt FROM sql_command;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;


    -- nacharbeiten
    set sql_command = concat('update ',temp_table_name,' set __id = ',dsx_get_key_sql( use_table_name ));
    PREPARE stmt FROM sql_command;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;    

    SET result = JSON_OBJECT(
        'success',1,
        'temporary_table_name',temp_table_name,
        'message','OK'
    );


    IF JSON_VALUE(request,'$.type')<>'delete' THEN
        call dsx_rest_api_set_handle_filedata(request,temp_table_name,use_table_name);
    END IF;


END //