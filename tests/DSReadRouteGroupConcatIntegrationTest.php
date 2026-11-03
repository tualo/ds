<?php

namespace Tualo\Office\Basic {
    class TualoApplication
    {
        public static function timing(string $message): void {}
        public static function deferredTrigger(): void {}

        public static function get(string $key): mixed
        {
            if ($key === 'configuration') return [];
            throw new \RuntimeException('Unexpected application variable: ' . $key);
        }

        public static function configuration(string $section, string $key, mixed $default = false): mixed
        {
            return $default;
        }

        public static function result(string $key, mixed $value): void {}
    }
}

namespace Tualo\Office\DS {
    class ErrorLogger
    {
        public static array $errors = [];

        public static function log(mixed $db, string $operation, string $tablename, \Throwable $error): void
        {
            self::$errors[] = $error;
        }
    }
}

namespace Tualo\Office\DSX {
    class ErrorLogger
    {
        public static array $errors = [];

        public static function log(mixed $db, string $operation, string $tablename, \Throwable $error, bool $connectionBusy = false): void
        {
            self::$errors[] = $error;
        }
    }
}

namespace {
    use Tualo\Office\Basic\MYSQL\Database;
    use Tualo\Office\DS\DSReadRoute;
    use Tualo\Office\DS\DSTable;
    use Tualo\Office\DSX\ErrorLogger;
    use Tualo\Office\DSX\Read\RestApiGet;

    $host = getenv('DS_TEST_MYSQL_HOST');
    $port = getenv('DS_TEST_MYSQL_PORT');
    if ($host === false || $port === false) {
        echo "Skipped: set DS_TEST_MYSQL_HOST and DS_TEST_MYSQL_PORT for an isolated test server\n";
        exit(0);
    }
    $user = getenv('DS_TEST_MYSQL_USER');
    $password = getenv('DS_TEST_MYSQL_PASSWORD');
    if ($user === false) $user = 'root';
    if ($password === false) $password = '';
    $bsc = getenv('DS_TEST_BSC_SRC') ?: dirname(__DIR__, 2) . '/bsc/src';
    $dsx = getenv('DS_TEST_DSX_SRC') ?: dirname(__DIR__, 2) . '/dsx/src';

    foreach (['BASIC/IRecordset.php', 'BASIC/RecordsetBasic.php', 'BASIC/Database_basic.php',
              'MYSQL/Recordset_mysql.php', 'MYSQL/Database_mysql.php', 'MYSQL/Database.php'] as $file) {
        require_once $bsc . '/' . $file;
    }
    require_once dirname(__DIR__) . '/src/DSReadRoute.php';
    require_once dirname(__DIR__) . '/src/DSTable.php';
    foreach (['SqlQuoter', 'AccessControl', 'TableDefinition', 'FilterBuilder', 'SortBuilder', 'RestApiGet'] as $class) {
        require_once $dsx . '/Read/' . $class . '.php';
    }

    function check(bool $condition, string $message): void
    {
        if (!$condition) throw new \RuntimeException($message);
    }

    function sessionLimit(Database $db): int
    {
        return (int)$db->singleValue('SELECT @@SESSION.group_concat_max_len AS value', [], 'value');
    }

    $procedureSource = file_get_contents(dirname(__DIR__) . '/src/sql/dsx/dsx_rest_api_get.sql');
    check(
        $procedureSource !== false
        && preg_match('/^[ \t]*SET\s+SESSION\s+group_concat_max_len\s*=\s*(\d+)\s*;/im', $procedureSource, $matches) === 1,
        'The configured procedure limit could not be determined'
    );
    $procedureLimit = (int)$matches[1];
    check($procedureLimit < 1073741824, 'The procedure must stay below the MariaDB 11.8.9 maximum');

    $admin = new \mysqli($host, $user, $password, '', (int)$port);
    $schema = 'ds_gc_test_' . bin2hex(random_bytes(6));
    $admin->query('CREATE DATABASE `' . $schema . '`');
    $db = null;
    try {
        $db = new Database($user, $password, $schema, $host, (int)$port);
        $db->direct('CREATE TABLE tasks (task_id VARCHAR(36), translator VARCHAR(10))');
        $db->direct('CREATE TABLE translators (customer VARCHAR(10), cost INT, email VARCHAR(255))');
        $db->direct("INSERT INTO tasks VALUES ('small', 's'), ('large', 'l')");
        $db->direct("INSERT INTO translators VALUES ('s', 0, 'sample@example.invalid')");
        $db->direct('CREATE TABLE digits (n INT PRIMARY KEY)');
        $db->direct('INSERT INTO digits VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)');
        $db->direct("
            INSERT INTO translators
            SELECT 'l', 0, CONCAT(d1.n, d2.n, d3.n, d4.n, REPEAT('x', 112), '@example.invalid')
            FROM digits d1 CROSS JOIN digits d2 CROSS JOIN digits d3 CROSS JOIN digits d4
        ");
        $db->direct("
            CREATE VIEW fixture_view AS
            SELECT h.task_id, a.customer, a.cost, JSON_ARRAYAGG(a.email) AS mail_addresses
            FROM tasks h JOIN translators a ON (a.customer, a.cost) = (h.translator, 0)
            GROUP BY h.task_id, h.translator
        ");
        $db->direct('CREATE TABLE ds_access (table_name VARCHAR(64), role VARCHAR(64), `read` TINYINT)');
        $db->direct('CREATE TABLE view_session_groups (`group` VARCHAR(64))');
        $db->direct('CREATE TABLE ds (table_name VARCHAR(64), displayfield VARCHAR(64), read_table VARCHAR(64), searchfield VARCHAR(64), searchany TINYINT)');
        $db->direct('CREATE TABLE ds_column (table_name VARCHAR(64), column_name VARCHAR(64), data_type VARCHAR(64), existsreal TINYINT, is_primary TINYINT, is_generated VARCHAR(64))');
        $db->direct("INSERT INTO ds_access VALUES ('fixture_view', 'test', 1)");
        $db->direct("INSERT INTO view_session_groups VALUES ('test')");
        $db->direct("INSERT INTO ds VALUES ('fixture_view', 'task_id', 'fixture_view', NULL, 0)");
        $db->direct("
            INSERT INTO ds_column VALUES
            ('fixture_view', 'task_id', 'varchar', 1, 1, 'NEVER'),
            ('fixture_view', 'customer', 'varchar', 1, 0, 'NEVER'),
            ('fixture_view', 'cost', 'int', 1, 0, 'NEVER'),
            ('fixture_view', 'mail_addresses', 'mediumtext', 1, 0, 'NEVER')
        ");
        $procedure = <<<'SQL'
            CREATE PROCEDURE dsx_rest_api_get(IN request JSON, OUT result JSON)
            BEGIN
                SET SESSION group_concat_max_len = __GROUP_CONCAT_LIMIT__;
                IF JSON_VALUE(request, '$.scenario') = 'large-truncated' THEN
                    SET SESSION group_concat_max_len = 1048576;
                END IF;
                IF JSON_VALUE(request, '$.scenario') = 'call-failure' THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fixture call failure';
                END IF;
                SELECT 'first result' AS fixture;
                IF JSON_VALUE(request, '$.scenario') = 'result-failure' THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fixture result failure';
                END IF;
                SELECT 'second result' AS fixture;
                SET result = JSON_OBJECT(
                    'success', TRUE,
                    'query', IF(JSON_VALUE(request, '$.scenario') IN ('large', 'large-truncated'),
                        'select * from fixture_view where task_id = ''large''',
                        'select * from fixture_view where task_id = ''small'''),
                    'order_by', '', 'limitterm', '', 'total', NULL
                );
            END
        SQL;
        $db->direct(str_replace('__GROUP_CONCAT_LIMIT__', (string)$procedureLimit, $procedure));

        $db->direct('SET SESSION group_concat_max_len = 1048576');
        $table = new DSTable($db, 'fixture_view');
        $table->read();
        check(!$table->error(), 'DSTable failed: ' . $table->errorMessage());
        check($table->getSingle()['mail_addresses'] === '["sample@example.invalid"]', 'The small JSON aggregate changed');
        check(sessionLimit($db) === $procedureLimit, 'The read did not retain the procedure session limit');

        foreach (['call-failure', 'result-failure'] as $scenario) {
            try {
                DSReadRoute::read($db, 'fixture_view', ['scenario' => $scenario]);
                throw new \RuntimeException('Expected ' . $scenario);
            } catch (\Throwable $error) {
                check(str_contains($error->getMessage(), 'fixture'), 'The original procedure error was hidden: ' . $error->getMessage());
            }
            check(str_starts_with($db->last_sql, 'call dsx_rest_api_get'), 'The failing statement was hidden');
            check(sessionLimit($db) === $procedureLimit, 'The procedure session limit changed after ' . $scenario);
        }

        try {
            DSReadRoute::read($db, 'fixture_view', ['scenario' => 'large-truncated']);
            throw new \RuntimeException('Expected an aggregate truncation failure');
        } catch (\RuntimeException $error) {
            check($error->getCode() === 1260, 'MariaDB aggregate truncation was not reported: ' . $error->getMessage());
        }
        check(sessionLimit($db) === 1048576, 'The session limit changed after the truncated read');

        $db->direct('SET SESSION group_concat_max_len = 2097152');
        $large = DSReadRoute::read($db, 'fixture_view', ['scenario' => 'large']);
        $addresses = json_decode($large['data'][0]['mail_addresses'], true, 512, JSON_THROW_ON_ERROR);
        check(count($addresses) === 10000, 'A large aggregate was cut short');
        check(sessionLimit($db) === $procedureLimit, 'The procedure session limit was not retained');

        $db->direct('SET SESSION group_concat_max_len = 4294967295');
        DSReadRoute::read($db, 'fixture_view', []);
        check(sessionLimit($db) === $procedureLimit, 'The procedure did not replace the excessive session limit');

        $db->direct('SET SESSION group_concat_max_len = 128');
        iterator_to_array($db->directIterate("SELECT * FROM fixture_view WHERE task_id = 'large'"), false);
        check($db->mysqli->warning_count > 0, 'The unbuffered aggregate warning was unavailable after iteration');
        $warning = $db->mysqli->get_warnings();
        check($warning !== false && $warning->errno === 1260, 'The unbuffered aggregate warning had an unexpected code');

        $request = [
            'tablename' => 'fixture_view',
            'limit' => 5,
            'filter' => [['property' => 'task_id', 'operator' => 'eq', 'value' => 'small']],
        ];
        $db->direct('SET SESSION group_concat_max_len = 1048576');
        $small = RestApiGet::read($db, $request);
        check($small['data'][0]['mail_addresses'] === '["sample@example.invalid"]', 'DSX changed the small JSON aggregate');

        $request['filter'][0]['value'] = 'large';
        $countRequest = $request;
        $countRequest['count'] = 1;
        $countRequest['filter'][] = ['property' => 'mail_addresses', 'operator' => 'is not null'];
        $countProbe = $db->singleValue(
            "SELECT COUNT(0) AS c FROM (SELECT * FROM fixture_view WHERE task_id = 'large' AND mail_addresses IS NOT NULL) x",
            [],
            'c'
        );
        check($countProbe === 1 && ($db->getWarnings()[0]['errno'] ?? null) === 1260, 'The fixture count did not produce the expected warning');
        $json = '';
        ErrorLogger::$errors = [];
        try {
            RestApiGet::readStream($db, $countRequest, function (string $chunk) use (&$json): void {
                $json .= $chunk;
            });
            throw new \RuntimeException('Expected DSX count aggregate truncation failure');
        } catch (\RuntimeException $error) {
            check($error->getCode() === 1260 && $json === '', 'DSX count did not report aggregate truncation before streaming: ' . $error->getMessage());
        }
        check(count(ErrorLogger::$errors) === 1, 'DSX count did not log aggregate truncation');

        $emptyRequest = $request;
        $emptyRequest['filter'][] = ['property' => 'mail_addresses', 'operator' => 'like', 'value' => 'does-not-match'];
        $json = '';
        ErrorLogger::$errors = [];
        try {
            RestApiGet::readStream($db, $emptyRequest, function (string $chunk) use (&$json): void {
                $json .= $chunk;
            });
            throw new \RuntimeException('Expected DSX empty-result aggregate truncation failure');
        } catch (\RuntimeException $error) {
            check($error->getCode() === 1260 && $json === '', 'DSX empty result did not report aggregate truncation before streaming: ' . $error->getMessage());
        }
        check(count(ErrorLogger::$errors) === 1, 'DSX empty result did not log aggregate truncation');

        ErrorLogger::$errors = [];
        try {
            RestApiGet::read($db, $request);
            throw new \RuntimeException('Expected DSX aggregate truncation failure');
        } catch (\RuntimeException $error) {
            check($error->getCode() === 1260, 'DSX did not report aggregate truncation: ' . $error->getMessage());
        }
        check(count(ErrorLogger::$errors) === 1, 'DSX direct read did not log aggregate truncation');

        $json = '';
        ErrorLogger::$errors = [];
        RestApiGet::readStream($db, $request, function (string $chunk) use (&$json): void {
            $json .= $chunk;
        });
        $streamed = json_decode($json, true, 512, JSON_THROW_ON_ERROR);
        check($streamed['success'] === false && str_contains($streamed['msg'], 'group_concat_max_len'), 'DSX stream returned truncated data as success');
        check(count(ErrorLogger::$errors) === 1, 'DSX stream did not log aggregate truncation');

        $db->direct('SET SESSION group_concat_max_len = 2097152');
        $large = RestApiGet::read($db, $request);
        $addresses = json_decode($large['data'][0]['mail_addresses'], true, 512, JSON_THROW_ON_ERROR);
        check(count($addresses) === 10000, 'DSX cut short a large aggregate despite an adequate limit');
        check(sessionLimit($db) === 2097152, 'DSX changed the session limit');

        echo 'MariaDB ' . $db->mysqli->server_info . " group_concat integration tests passed\n";
    } finally {
        if ($db !== null) $db->close();
        $admin->query('DROP DATABASE `' . $schema . '`');
        $admin->close();
    }
}
