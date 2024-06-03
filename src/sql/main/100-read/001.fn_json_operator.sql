DELIMITER //

DROP FUNCTION IF EXISTS `fn_json_operator` //
CREATE FUNCTION `fn_json_operator`(operator varchar(128))
RETURNS JSON
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
    IF operator='not in' THEN SET result='not åin'; END IF;

    RETURN result;
END //