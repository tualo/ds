<?php

namespace Tualo\Office\Basic {
    class TestLogger
    {
        public array $records = [];
        public bool $fail = false;

        public function error(string $message, array $context): void
        {
            if ($this->fail) throw new \RuntimeException('log sink unavailable');
            $this->records[] = ['message' => $message, 'context' => $context];
        }
    }

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
        public static ?TestLogger $testLogger = null;
        public static ?TestSession $session = null;
        public static array $testResult = [];

        public static function logger(string $channel): TestLogger
        {
            if ($channel !== 'dstable') throw new \RuntimeException('Unexpected log channel');
            return self::$testLogger ??= new TestLogger();
        }

        public static function get(string $key): mixed
        {
            if ($key === 'session') return self::$session;
            throw new \RuntimeException('Unexpected application variable');
        }

        public static function result(?string $key = null, mixed $value = null): ?array
        {
            if ($key === null) return self::$testResult;
            self::$testResult[$key] = $value;
            return null;
        }

        public static function contenttype(string $contenttype): void {}
    }

    class Route
    {
        public static array $handlers = [];
        public static bool $finished = false;

        public static function add(string $path, callable $handler, array $methods, bool $authenticated, array $fields = [], string $scope = ''): void
        {
            self::$handlers[$path] = $handler;
        }
    }
}

namespace Tualo\Office\DS {
    class DSReadRoute
    {
        public static function read(mixed $db, string $tablename, array $request): array
        {
            throw new \RuntimeException('legacy read failed');
        }
    }
}

namespace Tualo\Office\DS\Routes {
    class DSBase
    {
        public static function setRequestParameter(): void {}
    }

    class DefaultExpectedFields
    {
        public static array $Fields = [];
    }
}

namespace Tualo\Office\DS\Scopes {
    class DSReadScope
    {
        public static function identifier(): string
        {
            return 'read';
        }
    }
}

namespace Tualo\Office\DSX\Read {
    class StreamResponse
    {
        public static function send(mixed $db, array $request, ?callable $trailer = null): void
        {
            throw new \RuntimeException('old stream failed');
        }
    }
}

namespace {
    use Tualo\Office\Basic\Route;
    use Tualo\Office\Basic\TestLogger;
    use Tualo\Office\Basic\TestSession;
    use Tualo\Office\Basic\TualoApplication as App;
    use Tualo\Office\DS\DSTable;
    use Tualo\Office\DS\Routes\DS\Read;

    require_once dirname(__DIR__) . '/src/ErrorLogger.php';
    require_once dirname(__DIR__) . '/src/DSTable.php';
    require_once dirname(__DIR__) . '/src/Routes/DS/Read.php';

    function check(bool $condition, string $message): void
    {
        if (!$condition) throw new \RuntimeException($message);
    }

    class TestDatabase
    {
        public string $dbname = 'test_schema';
        public string $last_sql = '';

        public function direct(string $sql, array $parameters = []): bool
        {
            $this->last_sql = $sql;
            return true;
        }

        public function tinyIntAsBoolean(bool $value): bool
        {
            return $value;
        }
    }

    check(!class_exists(\Tualo\Office\DSX\ErrorLogger::class), 'The DSX logger must be absent in this test');
    check(!class_exists(\Tualo\Office\DSX\Write\RestApiSet::class), 'RestApiSet must be absent in this test');

    App::$testLogger = new TestLogger();
    $db = new TestDatabase();
    $table = new DSTable($db, 'example');
    check($table->update([['id' => 1]]) === false, 'Missing RestApiSet did not return an error');
    check($table->error() && str_contains($table->errorMessage(), 'Version 1.0.5'), 'Missing RestApiSet did not identify the required version');
    check(count(App::$testLogger->records) === 1, 'Missing RestApiSet was not logged');
    $context = App::$testLogger->records[0]['context'];
    check($context['operation'] === 'update' && $context['tablename'] === 'example', 'Fallback log context is incorrect');
    check(str_contains($context['dependency_error'], 'Version 1.0.5'), 'Fallback did not report the missing logger dependency');

    App::$testLogger = new TestLogger();
    $table = new DSTable($db, 'example');
    $table->read();
    check($table->error() && $table->errorMessage() === 'legacy read failed', 'Legacy read failure was not preserved');
    check(count(App::$testLogger->records) === 1 && App::$testLogger->records[0]['context']['operation'] === 'read', 'Legacy read failure was not logged');

    App::$testLogger = new TestLogger();
    App::$session = new TestSession($db);
    App::$testResult = ['success' => true];
    $_REQUEST = [];
    Read::register();
    $handler = Route::$handlers['/ds/(?P<tablename>\w+)/read'];
    $handler(['tablename' => 'example']);
    check(App::$testResult['success'] === false && App::$testResult['msg'] === 'old stream failed', 'Old stream failure was not returned');
    check(count(App::$testLogger->records) === 1 && App::$testLogger->records[0]['context']['operation'] === 'read', 'Old stream failure was not logged');

    $logFile = tempnam(sys_get_temp_dir(), 'ds-missing-log-');
    if ($logFile === false) throw new \RuntimeException('Could not create fallback log');
    $previousErrorLog = ini_get('error_log');
    try {
        ini_set('error_log', $logFile);
        App::$testLogger = new TestLogger();
        App::$testLogger->fail = true;
        $table = new DSTable($db, 'example');
        $table->read();
        check($table->error() && $table->errorMessage() === 'legacy read failed', 'A failed log sink masked the read error');
        $fallback = file_get_contents($logFile);
        check(is_string($fallback) && str_contains($fallback, 'log sink unavailable') && str_contains($fallback, 'Version 1.0.5'), 'Fallback failure was not surfaced');
    } finally {
        ini_set('error_log', $previousErrorLog === false ? '' : $previousErrorLog);
        unlink($logFile);
    }

    echo "Missing DSX logging compatibility tests passed\n";
}
