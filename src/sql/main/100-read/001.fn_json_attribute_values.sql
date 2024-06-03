DELIMITER //

DROP FUNCTION IF EXISTS `fn_json_attribute_values` //
CREATE FUNCTION `fn_json_attribute_values`( request JSON , attribute varchar(128))
RETURNS JSON
DETERMINISTIC
BEGIN 
    DECLARE i int;
    DECLARE row_count int;
    DECLARE result JSON default '[]';
    SET row_count = JSON_LENGTH(request);
    SET i = 0;
    WHILE i < row_count DO
        SET result = JSON_ARRAY_APPEND(result, '$', JSON_VALUE(request,CONCAT('$[',i,'].',attribute)) );
        SET i = i + 1;
    END WHILE;
    RETURN result;
END //


