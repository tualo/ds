<?php

namespace Tualo\Office\Basic {
    class TestSession
    {
        public function __construct(private object $db) {}

        public function getDB(): object
        {
            return $this->db;
        }
    }

    class TualoApplication
    {
        public static ?TestSession $session = null;
        public static array $results = [];

        public static function get(string $key): mixed
        {
            return match ($key) {
                'session' => self::$session,
                'configuration' => [],
                'tempPath' => '/tmp',
                default => throw new \RuntimeException('Unexpected application variable: ' . $key),
            };
        }

        public static function deferredTrigger(): void {}

        public static function configuration(string $section, string $key, mixed $default = false): mixed
        {
            return $default;
        }

        public static function result(string $key, mixed $value): void
        {
            self::$results[$key] = $value;
        }

        public static function contenttype(string $contenttype): void {}
    }

    class RouteWrapper {}

    class Route
    {
        public static array $handlers = [];

        public static function add(string $path, callable $handler, array $methods, bool $authenticated): void
        {
            self::$handlers[$path] = $handler;
        }
    }
}

namespace Tualo\Office\DS {
    class ErrorLogger
    {
        public static array $errors = [];
        public static array $operations = [];

        public static function log(mixed $db, string $operation, string $tablename, \Throwable $error): void
        {
            self::$errors[] = $error;
            self::$operations[] = $operation;
        }
    }

    class DSExporterHelper
    {
        public static array $exported = [];

        public static function getExportColumns(mixed $db, string $tablename): array
        {
            return [];
        }

        public static function exportDataToXSLX(mixed $db, string $tablename, array $columns, array $data, string $path, string &$filename, array $header): void
        {
            self::$exported = $data;
            $filename = 'test.xlsx';
        }
    }
}

namespace {
    use Tualo\Office\Basic\Route;
    use Tualo\Office\Basic\TestSession;
    use Tualo\Office\Basic\TualoApplication as App;
    use Tualo\Office\DS\DSExporterHelper;
    use Tualo\Office\DS\DSReadRoute;
    use Tualo\Office\DS\DSTable;
    use Tualo\Office\DS\ErrorLogger;
    use Tualo\Office\DS\Routes\Export;

    $src = dirname(__DIR__) . '/src/';
    require_once $src . 'DSReadRoute.php';
    require_once $src . 'DSTable.php';
    require_once $src . 'Routes/Export.php';

    function check(bool $condition, string $message): void
    {
        if (!$condition) throw new \RuntimeException($message);
    }

    const PROCEDURE_LIMIT = 173741824;

    class TestDatabase
    {
        public string $last_sql = '';
        public string $lastSQL = '';
        public array $statements = [];
        public array $warnings = [];
        public bool $aggregateTruncated = false;
        public bool $callReturnsFalse = false;
        public ?\Throwable $callFailure = null;
        public ?\Throwable $resultsFailure = null;

        public function __construct(public int $groupConcatMaxLen = 1048576) {}

        public function tinyIntAsBoolean(bool $value): bool
        {
            return $value;
        }

        public function direct(string $sql, array $parameters = []): array|bool
        {
            $this->last_sql = $this->lastSQL = $sql;
            $this->statements[] = $sql;
            $this->warnings = [];
            if (str_starts_with($sql, 'set @request')) return true;
            if (str_starts_with($sql, 'call dsx_rest_api_get')) {
                $this->groupConcatMaxLen = PROCEDURE_LIMIT;
                if ($this->callFailure !== null) throw $this->callFailure;
                if ($this->callReturnsFalse) return false;
                return true;
            }
            if (preg_match('/^SET SESSION group_concat_max_len\\s*=\\s*(\\d+);?$/i', $sql, $matches)) {
                $this->groupConcatMaxLen = (int)$matches[1];
                return true;
            }
            if (str_starts_with($sql, 'select * from fixture')) {
                if ($this->aggregateTruncated) {
                    $this->warnings[] = ['errno' => 1260, 'message' => 'Row was cut by JSON_ARRAYAGG()', 'sqlstate' => 'HY000'];
                }
                return [[
                    '__table_name' => 'example',
                    '__id' => '1',
                    '__displayfield' => '1',
                    'task_id' => 'example-task',
                    'mail_addresses' => $this->groupConcatMaxLen === 1073741824 ? '' : '["sample@example.invalid"]',
                ]];
            }
            throw new \RuntimeException('Unexpected SQL: ' . $sql);
        }

        public function singleValue(string $sql, array $parameters = [], string $key = ''): mixed
        {
            $this->last_sql = $this->lastSQL = $sql;
            $this->statements[] = $sql;
            $this->warnings = [];
            if (str_starts_with($sql, 'select @result')) {
                return json_encode([
                    'success' => true,
                    'query' => 'select * from fixture',
                    'order_by' => '',
                    'limitterm' => '',
                    'total' => null,
                ], JSON_THROW_ON_ERROR);
            }
            throw new \RuntimeException('Unexpected scalar SQL: ' . $sql);
        }

        public function moreResults(): array
        {
            if ($this->resultsFailure !== null) throw $this->resultsFailure;
            return [];
        }

        public function getWarnings(): array
        {
            return $this->warnings;
        }
    }

    $db = new TestDatabase();
    $table = new DSTable($db, 'example');
    $table->filter('task_id', '=', 'example-task')->limit(1)->read();
    check(!$table->error(), 'A normal DSTable read failed');
    check($table->getSingle()['mail_addresses'] === '["sample@example.invalid"]', 'DSTable returned a corrupted JSON aggregate');
    check($db->groupConcatMaxLen === PROCEDURE_LIMIT, 'The read did not retain the stored procedure session setting');
    check(str_starts_with($db->last_sql, 'select * from fixture'), 'The final data SQL was not retained');

    $db = new TestDatabase(2097152);
    $result = DSReadRoute::read($db, 'example', ['postprocessing' => 0]);
    check($result['data'][0]['mail_addresses'] === '["sample@example.invalid"]', 'The procedure session limit was not used for the data query');
    check($result['total'] === 1 && $db->groupConcatMaxLen === PROCEDURE_LIMIT, 'The procedure session limit or total was changed');

    $db = new TestDatabase(4294967295);
    DSReadRoute::read($db, 'example', []);
    check($db->groupConcatMaxLen === PROCEDURE_LIMIT, 'The procedure did not replace the original session limit');

    foreach (['callFailure', 'resultsFailure'] as $property) {
        $db = new TestDatabase();
        $error = new \RuntimeException('procedure failed');
        $db->$property = $error;
        try {
            DSReadRoute::read($db, 'example', []);
            throw new \RuntimeException('Expected procedure failure');
        } catch (\Throwable $actual) {
            check($actual === $error, 'The original procedure error was not preserved');
        }
        check($db->groupConcatMaxLen === PROCEDURE_LIMIT, 'The procedure session setting changed after an error');
        check(str_starts_with($db->last_sql, 'call dsx_rest_api_get'), 'The failing procedure SQL was hidden');
    }

    $db = new TestDatabase();
    $db->callReturnsFalse = true;
    try {
        DSReadRoute::read($db, 'example', []);
        throw new \RuntimeException('Expected an unsuccessful procedure call to fail');
    } catch (\RuntimeException $error) {
        check(str_contains($error->getMessage(), 'dsx_rest_api_get'), 'An unsuccessful procedure call was hidden');
    }
    check($db->groupConcatMaxLen === PROCEDURE_LIMIT, 'The procedure session setting changed after an unsuccessful call');

    $db = new TestDatabase();
    $db->aggregateTruncated = true;
    ErrorLogger::$errors = [];
    $table = new DSTable($db, 'example');
    $table->read();
    check($table->error() && str_contains($table->errorMessage(), 'group_concat_max_len'), 'Truncated aggregate data was returned as success');
    check(count(ErrorLogger::$errors) === 1, 'Truncated aggregate data was not logged');

    $db = new TestDatabase();
    App::$session = new TestSession($db);
    App::$results = [];
    DSExporterHelper::$exported = [];
    $_REQUEST = [];
    Export::register();
    $handler = Route::$handlers['/ds/(?P<tablename>\\w+)/export'];
    $handler(['tablename' => 'example']);
    check((App::$results['success'] ?? false) === true, 'Export failed');
    check(DSExporterHelper::$exported[0]['mail_addresses'] === '["sample@example.invalid"]', 'Export used a corrupted JSON aggregate');
    check($db->groupConcatMaxLen === PROCEDURE_LIMIT, 'Export did not retain the procedure session setting');
    check(!in_array('SET SESSION group_concat_max_len = 4294967295;', $db->statements, true), 'Export still sets the excessive session limit');

    $db = new TestDatabase();
    $db->aggregateTruncated = true;
    App::$session = new TestSession($db);
    App::$results = ['success' => true];
    DSExporterHelper::$exported = [];
    ErrorLogger::$errors = [];
    ErrorLogger::$operations = [];
    $handler(['tablename' => 'example']);
    check(App::$results['success'] === false && str_contains(App::$results['msg'], 'group_concat_max_len'), 'Export returned truncated data as success');
    check(count(ErrorLogger::$errors) === 1 && DSExporterHelper::$exported === [], 'Export failed to log the truncated read or exported damaged data');
    check(ErrorLogger::$operations === ['export'], 'Export failure was logged with the wrong operation');

    echo "DS read group_concat session tests passed\n";
}
