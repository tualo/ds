DELIMITER //
DROP FUNCTION IF EXISTS `FIELDQUOTE` //
CREATE FUNCTION `FIELDQUOTE`(in_str varchar(255))
RETURNS varchar(100)
DETERMINISTIC NO SQL
BEGIN
	RETURN concat('`',in_str,'`');
END //


DROP FUNCTION IF EXISTS `suppressRequires` //
CREATE FUNCTION `suppressRequires`()
RETURNS BOOLEAN
DETERMINISTIC NO SQL
BEGIN
	RETURN @suppressRequires=1;
END //


