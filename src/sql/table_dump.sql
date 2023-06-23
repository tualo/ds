DELIMITER //


CREATE OR REPLACE PROCEDURE `dump_table_content`( IN table_name varchar(255), IN wherefilter LONGTEXT , OUT result LONGTEXT)
BEGIN 

    DECLARE fieldlist LONGTEXT;
    DECLARE valueliste LONGTEXT;

    SELECT 
        group_concat(
            concat('`',column_name,'`') 
            order by ordinal_position
            separator ','
        ) 
    INTO 
        fieldlist 
    FROM 
        information_schema.columns 
    WHERE information_schema.columns.table_name = table_name and table_schema = database();

    FOR record IN (
        select * from 
    )
/*
    DECLARE done INT DEFAULT FALSE;
    DECLARE colname varchar(255);
    DECLARE cur1 CURSOR FOR SELECT column_name FROM information_schema.columns WHERE table_name = table_name and table_schema = database();
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    SET @sql = CONCAT('SELECT * FROM ', table_name, ' WHERE ', wherefilter);
    select @sql;
    SET @result = '';
    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO colname;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @sql = CONCAT(@sql, ' ', colname, ' = ', colname, ',');
    END LOOP;
    CLOSE cur1;
    SET @sql = CONCAT(@sql, ';');
    SET @result = @sql;
    SELECT @result INTO result;
    */
END //