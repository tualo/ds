-- MariaDB 11.6.9+: normalize column names, including view output columns.
-- Install this procedure in the selected database, then:
--   CALL ds_lowercase_identifiers('tualo', FALSE); -- preview only
--   CALL ds_lowercase_identifiers('tualo', TRUE);  -- execute
--
-- Back up the database and stop application writes/DDL before execution.
-- DDL commits implicitly; a failed run can leave earlier statements applied.
-- Table names must already be lowercase (automatic with lower_case_table_names=1).
-- Case-sensitive table renaming needs a separate dependency-aware migration.
-- Index/constraint/routine names and data are not lowercased.
-- Column references in views, triggers, routines and events remain valid because
-- MariaDB resolves column identifiers case-insensitively. Their SQL bodies and
-- application metadata are deliberately not rewritten.
-- View output names change, so clients using case-sensitive result keys must adapt.

DELIMITER //

CREATE OR REPLACE PROCEDURE ds_lowercase_identifiers(
    IN p_schema VARCHAR(64),
    IN p_execute BOOLEAN
)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_sql LONGTEXT DEFAULT NULL;
    DECLARE v_parts LONGTEXT;
    DECLARE v_qualified_name TEXT;
    DECLARE v_created_plan BOOLEAN DEFAULT FALSE;
    DECLARE v_prepared BOOLEAN DEFAULT FALSE;
    DECLARE v_client_charset VARCHAR(32) DEFAULT @@SESSION.character_set_client;
    DECLARE v_connection_collation VARCHAR(64) DEFAULT @@SESSION.collation_connection;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF v_prepared THEN
            DEALLOCATE PREPARE ds_lowercase_statement;
        END IF;
        SET SESSION character_set_client = v_client_charset;
        SET SESSION collation_connection = v_connection_collation;
        IF v_created_plan THEN
            SELECT v_sql AS failed_sql;
            SELECT step, object_name, sql_statement, applied
              FROM ds_lowercase_plan ORDER BY step;
            DROP TEMPORARY TABLE ds_lowercase_plan;
        END IF;
        SET @ds_lowercase_sql = NULL;
        RESIGNAL;
    END;

    IF p_schema IS NULL OR p_schema = '' OR p_execute IS NULL
       OR p_execute NOT IN (0, 1) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Specify a database name and FALSE (preview) or TRUE (execute).';
    END IF;

    IF LOWER(p_schema) IN ('mysql', 'information_schema', 'performance_schema', 'sys') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'System databases must not be normalized.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = p_schema
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Database does not exist or is not visible to the caller.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.TABLES
         WHERE TABLE_SCHEMA = p_schema
           AND BINARY TABLE_NAME <> BINARY LOWER(TABLE_NAME)
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mixed-case table names require a separate dependency-aware migration.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = p_schema
         GROUP BY TABLE_NAME, BINARY LOWER(COLUMN_NAME)
        HAVING COUNT(*) > 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lowercasing would produce duplicate column names.';
    END IF;

    IF p_execute AND @@SESSION.foreign_key_checks <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Enable foreign_key_checks before executing this procedure.';
    END IF;

    CREATE TEMPORARY TABLE ds_lowercase_plan (
        step INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        object_name VARCHAR(64) NOT NULL,
        sql_statement LONGTEXT NOT NULL,
        client_charset VARCHAR(32) NULL,
        connection_collation VARCHAR(64) NULL,
        applied BOOLEAN NOT NULL DEFAULT FALSE
    );
    SET v_created_plan = TRUE;

    FOR obj IN (
        SELECT t.TABLE_NAME, t.TABLE_TYPE
          FROM information_schema.TABLES t
         WHERE t.TABLE_SCHEMA = p_schema
           AND EXISTS (
               SELECT 1 FROM information_schema.COLUMNS c
                WHERE c.TABLE_SCHEMA = t.TABLE_SCHEMA
                  AND c.TABLE_NAME = t.TABLE_NAME
                  AND BINARY c.COLUMN_NAME <> BINARY LOWER(c.COLUMN_NAME)
           )
         ORDER BY t.TABLE_TYPE = 'VIEW', BINARY t.TABLE_NAME
    ) DO
        SET v_qualified_name = CONCAT(
            '`', REPLACE(p_schema, '`', '``'), '`.`',
            REPLACE(obj.TABLE_NAME, '`', '``'), '`'
        );
        SET v_parts = '';

        IF obj.TABLE_TYPE IN ('BASE TABLE', 'SYSTEM VERSIONED') THEN
            FOR col IN (
                SELECT COLUMN_NAME FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = p_schema AND TABLE_NAME = obj.TABLE_NAME
                   AND BINARY COLUMN_NAME <> BINARY LOWER(COLUMN_NAME)
                 ORDER BY ORDINAL_POSITION
            ) DO
                SET v_parts = CONCAT(
                    v_parts, IF(v_parts = '', '', ', '),
                    'RENAME COLUMN `', REPLACE(col.COLUMN_NAME, '`', '``'),
                    '` TO `', REPLACE(LOWER(col.COLUMN_NAME), '`', '``'), '`'
                );
            END FOR;
            INSERT INTO ds_lowercase_plan (object_name, sql_statement)
            VALUES (obj.TABLE_NAME, CONCAT('ALTER TABLE ', v_qualified_name, ' ', v_parts));
        ELSEIF obj.TABLE_TYPE = 'VIEW' THEN
            FOR col IN (
                SELECT COLUMN_NAME FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = p_schema AND TABLE_NAME = obj.TABLE_NAME
                 ORDER BY ORDINAL_POSITION
            ) DO
                SET v_parts = CONCAT(
                    v_parts, IF(v_parts = '', '', ', '),
                    '`', REPLACE(LOWER(col.COLUMN_NAME), '`', '``'), '`'
                );
            END FOR;
            IF NOT EXISTS (
                SELECT 1 FROM information_schema.VIEWS
                 WHERE TABLE_SCHEMA = p_schema AND TABLE_NAME = obj.TABLE_NAME
                   AND VIEW_DEFINITION IS NOT NULL AND VIEW_DEFINITION <> ''
            ) THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'A view definition is not visible; SHOW VIEW privileges are required.';
            END IF;
            INSERT INTO ds_lowercase_plan (
                object_name, sql_statement, client_charset, connection_collation
            )
            SELECT obj.TABLE_NAME,
                   CONCAT(
                       'CREATE OR REPLACE ALGORITHM=', v.ALGORITHM,
                       ' DEFINER=`',
                       REPLACE(LEFT(v.DEFINER,
                           CHAR_LENGTH(v.DEFINER) - CHAR_LENGTH(SUBSTRING_INDEX(v.DEFINER, '@', -1)) - 1),
                           '`', '``'),
                       '`@`', REPLACE(SUBSTRING_INDEX(v.DEFINER, '@', -1), '`', '``'),
                       '` SQL SECURITY ', v.SECURITY_TYPE,
                       ' VIEW ', v_qualified_name, ' (', v_parts, ') AS ',
                       v.VIEW_DEFINITION,
                       CASE v.CHECK_OPTION
                           WHEN 'NONE' THEN ''
                           ELSE CONCAT(' WITH ', v.CHECK_OPTION, ' CHECK OPTION')
                       END
                   ),
                   v.CHARACTER_SET_CLIENT, v.COLLATION_CONNECTION
              FROM information_schema.VIEWS v
             WHERE v.TABLE_SCHEMA = p_schema AND v.TABLE_NAME = obj.TABLE_NAME;
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'An affected object has an unsupported table type.';
        END IF;
    END FOR;

    IF p_execute THEN
        IF EXISTS (SELECT 1 FROM ds_lowercase_plan) THEN
            FOR item IN (SELECT * FROM ds_lowercase_plan ORDER BY step) DO
                SET v_sql = item.sql_statement;
                IF item.client_charset IS NOT NULL THEN
                    SET SESSION character_set_client = item.client_charset;
                    SET SESSION collation_connection = item.connection_collation;
                END IF;
                SET @ds_lowercase_sql = v_sql;
                PREPARE ds_lowercase_statement FROM @ds_lowercase_sql;
                SET v_prepared = TRUE;
                EXECUTE ds_lowercase_statement;
                DEALLOCATE PREPARE ds_lowercase_statement;
                SET v_prepared = FALSE;
                UPDATE ds_lowercase_plan SET applied = TRUE WHERE step = item.step;
            END FOR;
        END IF;
        IF EXISTS (
            SELECT 1 FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = p_schema
               AND BINARY COLUMN_NAME <> BINARY LOWER(COLUMN_NAME)
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Verification failed: mixed-case column names remain.';
        END IF;
    END IF;

    SET SESSION character_set_client = v_client_charset;
    SET SESSION collation_connection = v_connection_collation;
    SET @ds_lowercase_sql = NULL;
    SELECT step, object_name, sql_statement, applied
      FROM ds_lowercase_plan ORDER BY step;
    DROP TEMPORARY TABLE ds_lowercase_plan;
END //

DELIMITER ;
