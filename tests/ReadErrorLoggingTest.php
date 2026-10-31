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
        public static array $testResult = [];

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
        public static ?\Throwable $failure = null;

        public static function read(mixed $db, string $tablename, array $request): array
        {
            throw self::$failure ?? new \RuntimeException('dstable read failed', 11);
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

namespace Tualo\Office\DSX {
    class ErrorLogger
    {
        public static array $records = [];

        public static function log(mixed $db, string $operation, string $tablename, \Throwable $error, bool $connectionBusy = false): void
        {
            self::$records[] = compact('db', 'operation', 'tablename', 'error', 'connectionBusy');
        }
    }
}

namespace Tualo\Office\DSX\Write {
    class RestApiSet
    {
        public static function write(mixed $db, array $request): array
        {
            throw new \RuntimeException('dstable write failed', 12);
        }
    }
}

namespace Tualo\Office\DSX\Read {
    use Tualo\Office\DSX\ErrorLogger;

    class StreamResponse
    {
        public static ?\Throwable $failure = null;

        public static function send(mixed $db, array $request, ?callable $trailer = null): void
        {
            if (self::$failure !== null) {
                ErrorLogger::log($db, 'read', $request['tablename'], self::$failure);
                throw self::$failure;
            }
        }
    }
}

namespace {
    use Tualo\Office\Basic\Route;
    use Tualo\Office\Basic\TestSession;
    use Tualo\Office\Basic\TualoApplication as App;
    use Tualo\Office\DS\DSReadRoute;
    use Tualo\Office\DS\DSTable;
    use Tualo\Office\DS\Routes\DS\Read;
    use Tualo\Office\DSX\ErrorLogger;
    use Tualo\Office\DSX\Read\StreamResponse;

    require_once dirname(__DIR__) . '/src/ErrorLogger.php';
    require_once dirname(__DIR__) . '/src/DSTable.php';
    require_once dirname(__DIR__) . '/src/Routes/DS/Read.php';

    function check(bool $condition, string $message): void
    {
        if (!$condition) throw new \RuntimeException($message);
    }

    class TestDatabase
    {
        public string $last_sql = '';
        public ?\Throwable $setupFailure = null;

        public function direct(string $sql, array $parameters = []): bool
        {
            $this->last_sql = $sql;
            if ($this->setupFailure !== null) throw $this->setupFailure;
            return true;
        }

        public function tinyIntAsBoolean(bool $value): bool
        {
            return $value;
        }
    }

    $db = new TestDatabase();
    $table = new DSTable($db, 'example');
    $table->read();
    check($table->error() && $table->errorMessage() === 'dstable read failed', 'DSTable read error state changed');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['operation'] === 'read', 'DSTable read did not use the shared logger');
    check(ErrorLogger::$records[0]['tablename'] === 'example' && ErrorLogger::$records[0]['error']->getCode() === 11, 'DSTable read context is incorrect');

    ErrorLogger::$records = [];
    DSReadRoute::$failure = new \Error('dstable read type error');
    $table = new DSTable($db, 'example');
    $table->read();
    check($table->error() && $table->errorMessage() === 'dstable read type error', 'DSTable did not handle a read error');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['error'] === DSReadRoute::$failure, 'DSTable did not log the read error');
    DSReadRoute::$failure = null;

    ErrorLogger::$records = [];
    $table = new DSTable($db, 'example');
    check($table->update([['id' => 1]]) === false, 'DSTable write error return changed');
    check($table->error() && $table->errorMessage() === 'dstable write failed', 'DSTable write error state changed');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['operation'] === 'update', 'DSTable write did not use the shared logger');
    check(ErrorLogger::$records[0]['error']->getCode() === 12, 'DSTable write error context changed');

    Read::register();
    $handler = Route::$handlers['/ds/(?P<tablename>\w+)/read'];
    $_REQUEST = [];

    ErrorLogger::$records = [];
    App::$session = null;
    App::$testResult = ['success' => true];
    $handler(['tablename' => 'example']);
    check(App::$testResult['success'] === false && App::$testResult['last_sql'] === null, 'Missing session was not returned as an error');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['db'] === null, 'Missing session was not logged exactly once');

    ErrorLogger::$records = [];
    $db = new TestDatabase();
    $db->setupFailure = new \Error('request setup failed');
    App::$session = new TestSession($db);
    App::$testResult = ['success' => true];
    $handler(['tablename' => 'example']);
    check(App::$testResult['success'] === false && App::$testResult['msg'] === 'request setup failed', 'Setup failure was not returned as an error');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['error'] === $db->setupFailure, 'Setup failure was not logged exactly once');
    check(ErrorLogger::$records[0]['operation'] === 'read' && ErrorLogger::$records[0]['tablename'] === 'example', 'Setup failure log context is incorrect');

    ErrorLogger::$records = [];
    $db = new TestDatabase();
    App::$session = new TestSession($db);
    App::$testResult = ['success' => true];
    StreamResponse::$failure = new \RuntimeException('stream setup failed');
    $handler(['tablename' => 'example']);
    check(App::$testResult['success'] === false && App::$testResult['msg'] === 'stream setup failed', 'Stream setup failure was not returned');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['error'] === StreamResponse::$failure, 'Stream setup failure was logged more than once');

    ErrorLogger::$records = [];
    $db = new TestDatabase();
    App::$session = new TestSession($db);
    App::$testResult = ['success' => true];
    $legacyHandler = Route::$handlers['/.ds/(?P<tablename>\w+)/read'];
    $legacyHandler(['tablename' => 'example']);
    check(App::$testResult['success'] === false && App::$testResult['msg'] === 'dstable read failed', 'Legacy read failure was not returned');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['operation'] === 'read', 'Legacy read failure was not logged');

    ErrorLogger::$records = [];
    $db = new TestDatabase();
    App::$session = new TestSession($db);
    App::$testResult = ['success' => true];
    DSReadRoute::$failure = new \Error('single read failed');
    $singleHandler = Route::$handlers['/ds/(?P<tablename>\w+)/read/(?P<id>.+)'];
    $singleHandler(['tablename' => 'example', 'id' => '1']);
    check(App::$testResult['success'] === false && App::$testResult['msg'] === 'single read failed', 'Single read failure was not returned');
    check(count(ErrorLogger::$records) === 1 && ErrorLogger::$records[0]['error'] === DSReadRoute::$failure, 'Single read failure was not logged exactly once');
    DSReadRoute::$failure = null;

    echo "DSTable and read route logging tests passed\n";
}
