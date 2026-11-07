<?php

namespace Tualo\Office\Basic {
    class Route
    {
        public static array $handlers = [];
        public static function add($path, $handler, ...$options): void
        {
            self::$handlers[$path] = $handler;
        }
    }
    class TualoApplication
    {
        public static object $session;
        public static function get($key): object { return self::$session; }
        public static function result($key, $value): void {}
        public static function contenttype($value): void {}
    }
}

namespace Tualo\Office\DS\Routes {
    class DSBase {}
    class DefaultExpectedFields { public static array $Fields = []; }
}

namespace Tualo\Office\DS\Scopes {
    class DSReadScope
    {
        public static function identifier(): string { return 'ds.read'; }
    }
}

namespace Tualo\Office\DSX\Read {
    class StreamResponse
    {
        public static array $request;
        public static function send($db, $request, $trailer): void
        {
            self::$request = $request;
        }
    }
}

namespace {
    use Tualo\Office\Basic\Route;
    use Tualo\Office\Basic\TualoApplication as App;
    use Tualo\Office\DS\Routes\DS\Read;
    use Tualo\Office\DSX\Read\StreamResponse;

    $db = new class {
        public string $fulltextCount = '1';
        public function direct($sql, $parameters): void {}
        public function singleValue($sql, $parameters, $key): string { return $this->fulltextCount; }
    };
    App::$session = new class($db) {
        public function __construct(private object $db) {}
        public function getDB(): object { return $this->db; }
    };
    require dirname(__DIR__) . '/src/Routes/DS/Read.php';
    Read::register();
    $handler = Route::$handlers['/ds/(?P<tablename>\w+)/read'];
    foreach ([null, 0, 1, 2, '2'] as $mode) {
        $_REQUEST = ['search' => 'needle'];
        if ($mode !== null) $_REQUEST['fulltext'] = $mode;
        $handler(['tablename' => 'adressen']);
        $expected = $mode ?? 2;
        if (StreamResponse::$request['fulltext'] !== $expected) {
            throw new \RuntimeException('Fulltext mode was not passed to the reader');
        }
    }
    $db->fulltextCount = '0';
    $_REQUEST = ['search' => 'needle', 'fulltext' => 2];
    $handler(['tablename' => 'adressen']);
    if (isset(StreamResponse::$request['fulltext'])) {
        throw new \RuntimeException('Fulltext mode retained without a registered search table');
    }
    echo "Read fulltext request tests passed\n";
}
