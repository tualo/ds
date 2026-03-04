delimiter //

CREATE TABLE `long_running_processes` (
	`id` varchar(36) primary key,
	`process_name` varchar(128) not null,
	`started` datetime not null,
	`finshed` datetime default null,
	`last_contact` datetime not null
) //

CREATE OR REPLACE PROCEDURE `delete_clustersafe`( 
	IN table_name varchar(128), 
	in filter_by longtext,
    in counts integer
) COMMENT '
	Löscht Datensätze aus einer Tabelle in sicheren Batches,
	um Locking-Probleme zu vermeiden.
	Parameter:
	  - table_name: Name der Quell-Tabelle
	  - filter_by: WHERE-Bedingung als String
	  - counts: Anzahl zu löschender Datensätze
'
BEGIN 

	DECLARE v_sql longtext;
    DECLARE v_limit integer default 100;

    for rec in (select seq from seq_1_to_100000 where seq <= counts / v_limit) do
        SET v_sql = CONCAT('delete from `', table_name, '` where ', filter_by, ' limit ',v_limit);
        select 'start ...', rec.seq;
        PREPARE stmt FROM v_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    end for;
END //

CREATE  OR REPLACE PROCEDURE `create_materialized_table`( 
	IN  table_name varchar(128), 
	in filter varchar(255),
	in us_as_primary varchar(255)
) COMMENT 'Erstellt eine materialisierte Kopie einer Tabelle oder View
	mit hochperformanter Batch-Verarbeitung.
	Parameter:
	  - table_name: Name der Quell-Tabelle oder View
	  - filter: WHERE-Bedingung als String (z.B. year >= 2018)
	  - us_as_primary: Spalte(n) für Primary Key
	Ergebnis: Tabelle materialized_{table_name} mit gefilterten Daten'
BEGIN 

	DECLARE v_target varchar(255);
	DECLARE v_batch int DEFAULT 10000;
	DECLARE v_offset bigint DEFAULT 0;
	DECLARE v_rows bigint DEFAULT 0;
	DECLARE v_total bigint DEFAULT 0;
	DECLARE v_sql longtext;
	DECLARE v_table_type varchar(32);

	SET v_target = CONCAT('materialized_', table_name);


		/*

		*/
	IF exists(select table_name from information_schema.tables where table_name= CONCAT('materialized_', table_name) and table_schema= database() ) THEN
		for rec in (select seq from seq_1_to_100) do
			SET v_sql = CONCAT('DELETE FROM `', v_target, '` limit 1000');
			PREPARE stmt FROM v_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		end for;

	END IF;

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


	SET v_sql = CONCAT('ALTER TABLE `', v_target, '` ADD PRIMARY KEY (', us_as_primary, ')');


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


    --  call create_materialized_table('view_umsatzprognose','year >=2018','view_primary');
    -- KEY `idx_materialized_view_umsatzprognose_year` (`year`),
    -- KEY `idx_materialized_view_umsatzprognose_year_month` (`year`,`month`)
    -- fehlend primary key
END //