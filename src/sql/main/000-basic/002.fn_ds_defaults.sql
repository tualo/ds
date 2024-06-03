DELIMITER //

DROP FUNCTION IF EXISTS `fn_serial_sql` //
CREATE FUNCTION fn_serial_sql(in_table_name varchar(128),in_column_name varchar(128))
RETURNS LONGTEXT
DETERMINISTIC
BEGIN 
    DECLARE res LONGTEXT;
    select 
        concat( 'set @serial = (select ifnull(max(',column_name,'),',default_min_value-1,')+1 i from ',table_name,' where ',column_name,' between ',default_min_value,'-1 and ',default_max_value , ' having i <= ',default_max_value,');') x
    INTO res
    from ds_column where table_name=in_table_name and column_name=in_column_name;
    RETURN res;
END //

DROP FUNCTION IF EXISTS `fn_ds_defaults` //
CREATE FUNCTION `fn_ds_defaults`( str_fieldvalue varchar(255) , record JSON)
RETURNS LONGTEXT
DETERMINISTIC
BEGIN 
    IF str_fieldvalue = '{#serial}' THEN RETURN '@serial';
    ELSEIF str_fieldvalue = '{DATETIME}' THEN RETURN 'now()';
    ELSEIF str_fieldvalue = '{DATE}' THEN RETURN 'CURRENT_DATE';
    ELSEIF str_fieldvalue = '{TIME}' THEN RETURN 'CURRENT_TIME';
    ELSEIF str_fieldvalue = '{GUID}' THEN RETURN 'CURRENT_TIME';
    ELSEIF str_fieldvalue is not null THEN
        IF SUBSTRING(str_fieldvalue,1,2)='{:' and SUBSTRING(str_fieldvalue,length(str_fieldvalue),1)='}' THEN
            RETURN SUBSTRING(str_fieldvalue,3,length(str_fieldvalue)-3) ;
        ELSE
            RETURN quote(str_fieldvalue);
        END IF;
    END IF;
    RETURN str_fieldvalue;
END //
