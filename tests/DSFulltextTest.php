<?php

namespace Tualo\Office\Basic {
    class RouteWrapper {}
    class Route
    {
        public static $handler;
        public static function add($path, $handler, $methods, $authenticated, $options, $scope): void
        {
            if ($path !== '/dsft/run' || $methods !== ['post'] || !$authenticated || $scope !== 'ds.procedures') {
                throw new \RuntimeException('Unexpected route permissions');
            }
            self::$handler = $handler;
        }
    }
    class TualoApplication
    {
        public static $session;
        public static array $results = [];
        public static function get($key) { return self::$session; }
        public static function result($key, $value): void { self::$results[$key] = $value; }
        public static function contenttype($type): void {}
    }
}

namespace Tualo\Office\DS {
    class ErrorLogger
    {
        public static array $errors = [];
        public static function log($db, $operation, $table, $error): void
        {
            self::$errors[] = $error;
        }
    }
}

namespace {
    use Tualo\Office\Basic\Route;
    use Tualo\Office\Basic\TualoApplication as App;
    use Tualo\Office\DS\ErrorLogger;
    use Tualo\Office\DS\Routes\DSFulltext;

    require dirname(__DIR__) . '/src/Routes/DSFulltext.php';
    $db = new class {
        public array $calls = [];
        public bool $hasTable = true;
        public bool $hasFields = true;
        public bool $fail = false;
        public int $drained = 0;
        public function singleRow($sql, $parameters): array
        {
            return (str_contains($sql, 'ds_searchfields') ? $this->hasFields : $this->hasTable)
                ? ['table_name' => 'adressen'] : [];
        }
        public function direct($sql, $parameters = []): void
        {
            $this->calls[] = [$sql, $parameters];
            if ($this->fail) throw new \RuntimeException('Database failure');
        }
        public function moreResults(): array { $this->drained++; return []; }
        public function getWarnings(): array { return []; }
    };
    App::$session = new class($db) {
        public bool $master = true;
        public function __construct(private object $db) {}
        public function getDB(): object { return $this->db; }
        public function isMaster(): bool { return $this->master; }
    };
    function check($condition, $message): void
    {
        if (!$condition) throw new \RuntimeException($message);
    }
    DSFulltext::register();
    foreach (['build', 'refresh'] as $stage) {
        $_POST = ['table_name' => 'adressen', 'stage' => $stage];
        (Route::$handler)([]);
        check(App::$results['success'], 'Valid fulltext step failed');
    }
    check($db->calls === [
        ['call ds_create_fulltext_search({table_name})', ['table_name' => 'adressen']],
        ['call `refresh_searchft_adressen`()', []],
    ], 'Incorrect procedure calls or order');
    check($db->drained === 2, 'Procedure result sets not consumed');
    foreach ([
        ['table_name' => '', 'stage' => 'build'],
        ['table_name' => 'adressen; DROP TABLE ds', 'stage' => 'refresh'],
        ['table_name' => ['adressen'], 'stage' => 'build'],
        ['table_name' => 'adressen', 'stage' => 'invalid'],
    ] as $post) {
        $_POST = $post;
        (Route::$handler)([]);
        check(!App::$results['success'], 'Invalid request accepted');
    }
    $_POST = ['table_name' => 'adressen', 'stage' => 'build'];
    App::$session->master = false;
    (Route::$handler)([]);
    check(!App::$results['success'] && http_response_code() === 403, 'Non-master request accepted');
    App::$session->master = true;
    $db->hasFields = false;
    (Route::$handler)([]);
    check(!App::$results['success'], 'Missing search fields accepted');
    $db->hasFields = true;
    $db->hasTable = false;
    (Route::$handler)([]);
    check(!App::$results['success'], 'Unknown table accepted');
    check(count($db->calls) === 2, 'Rejected requests executed SQL');
    $db->hasTable = true;
    $db->fail = true;
    (Route::$handler)([]);
    check(!App::$results['success'] && App::$results['msg'] === 'Database failure', 'Database error hidden');
    check(count(ErrorLogger::$errors) === 8, 'Errors were not logged');
    echo "DSFulltext tests passed\n";
}
