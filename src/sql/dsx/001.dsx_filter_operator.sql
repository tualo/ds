DELIMITER //
CREATE OR REPLACE FUNCTION `dsx_filter_operator`(operator varchar(128))
RETURNS varchar(128)
DETERMINISTIC
BEGIN 
    DECLARE result varchar(128) default '=';
    
    IF operator='==' or operator='eq' THEN SET result='='; END IF;
    IF operator='!=' or operator='not' or operator='neq' THEN SET result='<>'; END IF;
    IF operator='>=' or operator='gt' THEN SET result='>='; END IF;
    IF operator='<=' or operator='lt' THEN SET result='<='; END IF;
    IF operator='not like' THEN SET result='not like'; END IF;
    IF operator='like' THEN SET result='like'; END IF;
    IF operator='in' THEN SET result='in'; END IF;
    IF operator='not in' THEN SET result='not in'; END IF;
    RETURN result;
END //