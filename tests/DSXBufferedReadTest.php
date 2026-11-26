<?php

namespace Tualo\Office\Basic {
    class TualoApplication
    {
        public static function deferredTrigger(): void {}
        public static function configuration(string $section, string $key, mixed $default = false): mixed { return $default; }
    }

    class Route
    {
        public static function canAccessByScope(string $scope): bool { return true; }
    }
}

namespace Tualo\Office\Basic\MYSQL {
    class Database
    {
        public object $mysqli;
        public array $statements = [];
        public bool $allowRead = true;
        public array $warnings = [];

        public function __construct()
        {
            $this->mysqli = new class { public int $warning_count = 0; };
        }

        public function tinyIntAsBoolean(bool $value): bool { return $value; }
        public function escape_string(string $value): string { return addslashes($value); }
        public function getWarnings(): array { return $this->warnings; }

        public function direct(string $sql, array $parameters = []): array|bool
        {
            $this->statements[] = $sql;
            if (str_starts_with($sql, 'SET SESSION') || str_starts_with($sql, 'set @request_options')) return true;
            if (str_contains($sql, 'from ds_access')) return $this->allowRead ? [['table_name' => 'example']] : [];
            if (str_contains($sql, 'from ds_column')) return [
                ['column_name' => 'id', 'data_type' => 'int', 'existsreal' => 1, 'is_primary' => 1, 'is_generated' => 'NEVER'],
                ['column_name' => 'name', 'data_type' => 'varchar', 'existsreal' => 1, 'is_primary' => 0, 'is_generated' => 'NEVER'],
            ];
            throw new \RuntimeException('Unexpected SQL: ' . $sql);
        }

        public function singleRow(string $sql, array $parameters = []): array
        {
            return ['table_name' => 'example', 'read_table' => 'example', 'displayfield' => 'name', 'searchfield' => 'name', 'searchany' => 0];
        }

        public function directIterate(string $sql): \Generator
        {
            $this->statements[] = $sql;
            yield ['__table_name' => 'example', '__id' => '1', '__displayfield' => 'Alpha', 'id' => 1, 'name' => 'Alpha'];
        }
    }
}

namespace Tualo\Office\DS\Routes {
    class DSBase
    {
        public static function sanitizeInput(string $input): string { return $input; }
    }
}

namespace Tualo\Office\DS\Scopes {
    class DSReadScope
    {
        public static function identifier(): string { return 'ds.read'; }
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
    use Tualo\Office\DS\DSTable;
    use Tualo\Office\DS\Routes\DS\Direct;
    use Tualo\Office\DSX\ErrorLogger;

    $dsx = getenv('DS_TEST_DSX_SRC') ?: dirname(__DIR__, 2) . '/dsx/src';
    foreach (['SqlQuoter', 'AccessControl', 'TableDefinition', 'FilterBuilder', 'SortBuilder', 'RestApiGet'] as $class) {
        require_once $dsx . '/Read/' . $class . '.php';
    }
    foreach (['ErrorLogger.php', 'DSXRead.php', 'DSTable.php', 'Routes/DS/Direct.php'] as $file) {
        require_once dirname(__DIR__) . '/src/' . $file;
    }

    function check(bool $condition, string $message): void
    {
        if (!$condition) throw new \RuntimeException($message);
    }

    $db = new Database();
    $table = new DSTable($db, 'example');
    $table->filter('name', 'eq', 'Alpha')->sort('id', 'DESC')->start(2)->limit(3)->read();
    check(!$table->error() && $table->getSingle()['name'] === 'Alpha', 'DSTable did not return DSX data');
    $sql = end($db->statements);
    check(str_contains($sql, "`name` = 'Alpha'") && str_contains($sql, '`id` desc') && str_contains($sql, 'LIMIT 2, 3'), 'DSTable query lost filtering, sorting or pagination');
    check(in_array('SET SESSION group_concat_max_len = 173741820', $db->statements, true), 'DSTable did not preserve the aggregate limit');

    $dispatch = new \ReflectionMethod(Direct::class, 'dispatch');
    $call = ['action' => 'TualoDS', 'method' => 'read', 'tid' => 1, 'data' => ['example', [
        'start' => 2, 'limit' => 3, 'shortfieldnames' => 0, 'fields' => '["id"]',
    ]]];
    $event = $dispatch->invoke(null, $db, $call);
    check($event['result'] === ['success' => true, 'data' => [['example__id' => 1]], 'total' => 1], 'Direct field selection or result format changed');
    check(str_contains(end($db->statements), 'LIMIT 2, 3'), 'Direct pagination was lost');

    $db->allowRead = false;
    ErrorLogger::$errors = [];
    $event = $dispatch->invoke(null, $db, $call);
    check($event['type'] === 'exception' && count(ErrorLogger::$errors) === 1, 'Direct access failure was not logged exactly once');
    $db->allowRead = true;
    $db->warnings = [['errno' => 1260, 'message' => 'Row was cut by JSON_ARRAYAGG()']];
    ErrorLogger::$errors = [];
    $table = new DSTable($db, 'example');
    $table->read();
    check($table->error() && str_contains($table->errorMessage(), 'group_concat_max_len'), 'DSTable accepted a truncated aggregate');
    check(count(ErrorLogger::$errors) === 1, 'DSTable aggregate failure was not logged exactly once');
    foreach ($db->statements as $statement) {
        check(!str_contains(strtolower($statement), 'call dsx_rest_api_get'), 'The stored procedure was called');
    }

    echo "DSX buffered read tests passed\n";
}
