delimiter //

CREATE DEFINER=`user_fb_wvd`@`%` PROCEDURE `create_materialized_table`( IN  table_name varchar(128), in filter varchar(255))
BEGIN 

	DECLARE v_target varchar(255);
	DECLARE v_batch int DEFAULT 10000;
	DECLARE v_offset bigint DEFAULT 0;
	DECLARE v_rows bigint DEFAULT 0;
	DECLARE v_total bigint DEFAULT 0;
	DECLARE v_sql longtext;
	DECLARE v_table_type varchar(32);

	SET v_target = CONCAT('materialized_', table_name);

	SET v_sql = CONCAT('DROP TABLE IF EXISTS `', v_target, '`');
	PREPARE stmt FROM v_sql;
	EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

	SET v_sql = CONCAT('SELECT COUNT(*) INTO @v_total FROM `', table_name, '` where ',filter);
	PREPARE stmt FROM v_sql;
	EXECUTE stmt ;
	DEALLOCATE PREPARE stmt;
    SET v_total = @v_total;
    select @v_total;

	SELECT t.table_type
	INTO v_table_type
	FROM information_schema.tables t
	WHERE t.table_schema = DATABASE()
		AND t.table_name = table_name
	LIMIT 1;

	IF v_table_type = 'VIEW' THEN
		SET v_sql = CONCAT(
			'CREATE TABLE `', v_target, '` AS SELECT * FROM `', table_name, '` WHERE 1=0'
		);
	ELSE
		SET v_sql = CONCAT('CREATE TABLE `', v_target, '` LIKE `', table_name, '`');
	END IF;
	PREPARE stmt FROM v_sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	read_loop: LOOP
		IF v_offset >= v_total THEN
			LEAVE read_loop;
		END IF;
		SET v_sql = CONCAT(
			'INSERT INTO `', v_target, '` SELECT * FROM `', table_name, '` where ',filter,' LIMIT ',
			v_offset, ', ', v_batch
		);
		PREPARE stmt FROM v_sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;

		SET v_offset = v_offset + v_batch;
	END LOOP read_loop;


    --  call create_materialized_table('view_umsatzprognose','year >=2018');
    -- KEY `idx_materialized_view_umsatzprognose_year` (`year`),
    -- KEY `idx_materialized_view_umsatzprognose_year_month` (`year`,`month`)
    -- fehlend primary key
END //