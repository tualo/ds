<?php

namespace Tualo\Office\DS\Routes\DS;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSTable;
use Tualo\Office\DS\ErrorLogger;
use Tualo\Office\DS\Routes\DSBase;
use Tualo\Office\DS\Routes\DS as DSRoutes;
use Tualo\Office\DS\Scopes\DSReadScope;

/**
 * Optionaler Ext.Direct-Router für DS-Operationen.
 *
 * Bündelt mehrere Store-Operationen (read, readSingle, create, update, destroy)
 * in einen HTTP-Request nach dem Ext.Direct-Remoting-Protokoll. Dadurch fallen
 * PHP-Bootstrap, Session-Handling und DB-Connect pro gebündeltem Aufruf nur
 * einmal an — relevant insbesondere bei entfernten Datenbanken (WAN-Latenz).
 *
 * Aktivierung über die Konfiguration:
 *   [ds]
 *   direct = 1                ; Feature einschalten (Default: aus)
 *   direct_batch_limit = 25   ; max. Sub-Requests pro Batch
 *   direct_buffer = 10        ; Client-Pufferfenster in ms (Ext enableBuffer)
 *
 * Die Zugriffsrechte entsprechen exakt den bestehenden Einzelrouten:
 * read/readSingle erfordern den Scope ds.read, Schreiboperationen eine aktive
 * Session; die Tabellenrechte erzwingt wie bisher die Datenbankschicht.
 */
class Direct extends DSBase
{
    const ACTION = 'TualoDS';
    const METHODS = ['read', 'readSingle', 'create', 'update', 'destroy'];

    public static function scope(): string
    {
        return 'basic';
    }

    public static function enabled(): bool
    {
        return App::configuration('ds', 'direct', '0') == '1';
    }

    public static function register()
    {
        Route::add('/.ds/direct/api.js', function ($matches) {
            App::contenttype('application/javascript');
            if (!self::enabled()) {
                App::body('// tualo ds direct is disabled (set [ds] direct = 1)');
                Route::$finished = true;
                return;
            }
            $provider = json_encode([
                'id' => 'tualo-ds-direct',
                'type' => 'remoting',
                'url' => './.ds/direct/router',
                'namespace' => 'Tualo.DS.API',
                'enableBuffer' => (int)App::configuration('ds', 'direct_buffer', 10),
                'maxRetries' => 0,
                'timeout' => 600000,
                'actions' => [
                    self::ACTION => array_map(
                        fn($m) => ['name' => $m, 'len' => 2],
                        self::METHODS
                    )
                ]
            ], JSON_UNESCAPED_SLASHES);
            App::body(implode("\n", [
                '(function(){',
                '    function init(){',
                '        Ext.ns(\'Tualo.DS\');',
                '        if (!Ext.direct || !Ext.direct.Manager) { return; }',
                '        if (Ext.direct.Manager.getProvider(\'tualo-ds-direct\')) { return; }',
                '        Ext.direct.Manager.addProvider(' . $provider . ');',
                '    }',
                '    if (window.Ext && Ext.onReady) { Ext.onReady(init); }',
                '    else if (window.addEventListener) { window.addEventListener(\'load\', function(){ if (window.Ext && Ext.onReady) { Ext.onReady(init); } }); }',
                '})();'
            ]));
            Route::$finished = true;
        }, ['get'], true);

        Route::add('/.ds/direct/router', function ($matches) {
            App::contenttype('application/json');
            if (!self::enabled()) {
                http_response_code(404);
                App::body(json_encode([self::exceptionEvent(null, 'ds direct is disabled')]));
                Route::$finished = true;
                return;
            }

            $calls = json_decode(file_get_contents('php://input'), true);
            // single (unbuffered) call arrives as an object, not an array of calls
            if (is_array($calls) && isset($calls['action'])) {
                $calls = [$calls];
            }
            if (!is_array($calls)) {
                http_response_code(400);
                App::body(json_encode([self::exceptionEvent(null, 'invalid request body')]));
                Route::$finished = true;
                return;
            }
            $limit = (int)App::configuration('ds', 'direct_batch_limit', 25);
            if (count($calls) > $limit) {
                http_response_code(400);
                App::body(json_encode([self::exceptionEvent(null, 'batch limit exceeded (' . $limit . ')')]));
                Route::$finished = true;
                return;
            }

            $db = App::get('session')->getDB();
            $events = [];
            foreach ($calls as $call) {
                $events[] = self::dispatch($db, $call);
            }
            App::body(json_encode($events, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE));
            Route::$finished = true;
        }, ['post'], true);
    }

    private static function exceptionEvent($call, string $message): array
    {
        return [
            'type' => 'exception',
            'tid' => is_array($call) && isset($call['tid']) ? $call['tid'] : null,
            'action' => self::ACTION,
            'method' => is_array($call) && isset($call['method']) ? $call['method'] : null,
            'message' => $message,
        ];
    }

    private static function dispatch($db, $call): array
    {
        if (
            !is_array($call)
            || ($call['action'] ?? '') !== self::ACTION
            || !in_array($call['method'] ?? '', self::METHODS, true)
            || !isset($call['tid'])
        ) {
            return self::exceptionEvent(is_array($call) ? $call : null, 'invalid direct call');
        }
        $method = $call['method'];
        $data = isset($call['data']) && is_array($call['data']) ? $call['data'] : [];
        $tablename = isset($data[0]) && is_string($data[0]) ? $data[0] : '';
        $payload = $data[1] ?? [];
        try {
            if ($tablename === '' || !preg_match('/^[a-zA-Z0-9_]+$/', $tablename)) {
                throw new Exception('invalid tablename');
            }
            if (in_array($method, ['read', 'readSingle'], true) && !Route::canAccessByScope(DSReadScope::identifier())) {
                throw new Exception('forbidden', 15403);
            }
            $result = match ($method) {
                'read' => self::read($db, $tablename, is_array($payload) ? $payload : []),
                'readSingle' => self::readSingle($db, $tablename, $payload),
                'create' => self::create($db, $tablename, $payload),
                'update' => self::update($db, $tablename, $payload),
                'destroy' => self::destroy($db, $tablename, $payload),
            };
            return [
                'type' => 'rpc',
                'tid' => $call['tid'],
                'action' => self::ACTION,
                'method' => $method,
                'result' => $result,
            ];
        } catch (\Throwable $e) {
            $op = match ($method) {
                'read', 'readSingle' => 'read',
                'create' => 'create',
                'update' => 'update',
                'destroy' => 'delete',
            };
            ErrorLogger::log($db, $op, $tablename, $e);
            $event = self::exceptionEvent($call, $e->getMessage());
            $event['result'] = ['success' => false, 'msg' => $e->getMessage(), 'code' => $e->getCode()];
            return $event;
        }
    }

    private static function applyRequestParameter($db, array $params): void
    {
        if (!isset($params['query_parameter'])) {
            return;
        }
        $json = is_string($params['query_parameter'])
            ? json_decode($params['query_parameter'], true)
            : $params['query_parameter'];
        if (!is_null($json)) {
            $db->execute('set @request_parameter={request_parameter}', [
                'request_parameter' => json_encode($json)
            ]);
        }
    }

    private static function read($db, string $tablename, array $input): array
    {
        $db->tinyIntAsBoolean(true);
        self::applyRequestParameter($db, $input);
        if (!isset($input['request_options'])) {
            $input['request_options'] = [];
        }
        $db->direct('set @request_options = {request_options};', [
            'request_options' => json_encode($input['request_options'])
        ]);

        if (isset($input['filter_by_search']) && ($input['filter_by_search'] == 1) && !isset($input['fulltext'])) {
            $sql = "select count(*) c from ds where table_name = 'ds_ftsearch_" . $tablename . "'";
            $count = $db->singleValue($sql, [], 'c');
            if ($count > 0) {
                $input['filter_by_search'] = 2;
                $input['fulltext'] = 2;
            }
        }
        if (isset($input['search'])) {
            $input['search'] = self::sanitizeInput($input['search']);
        }

        $read = DSReadRoute::read($db, $tablename, $input);
        return ['success' => true, 'data' => $read['data'], 'total' => $read['total']];
    }

    private static function readSingle($db, string $tablename, $id): array
    {
        $db->tinyIntAsBoolean(true);
        $table = new DSTable($db, $tablename);
        $read = $table->f('__id', 'eq', $id)->get();
        if ($table->error()) {
            throw new Exception($table->errorMessage());
        }
        return ['success' => true, 'data' => $read];
    }

    private static function create($db, string $tablename, $input): array
    {
        if (is_null($input)) {
            throw new Exception('Error Processing Request', 1);
        }
        $db->tinyIntAsBoolean(true);
        $table = new DSTable($db, $tablename);
        if (($result = $table->insert($input)) !== false) {
            if ($table->error()) {
                throw new Exception($table->errorMessage());
            }
            $warnings = $table->warnings();
            $moreResults = $table->moreResults();
            App::deferredTrigger();
            return [
                'success' => true,
                'warnings' => $warnings,
                'moreResults' => $moreResults,
                'data' => DSRoutes::readWrittenRows($db, $tablename, $result),
            ];
        }
        throw new Exception($table->errorMessage() !== '' ? $table->errorMessage() : 'insert failed');
    }

    private static function update($db, string $tablename, $input): array
    {
        if (is_null($input)) {
            throw new Exception('Error Processing Request', 1);
        }
        $db->tinyIntAsBoolean(true);
        $table = new DSTable($db, $tablename);
        $o = [];
        if ($db->singleValue(
            'select ifnull(read_table,"") v from ds where table_name = {tablename} and use_insert_for_update=1',
            ['tablename' => $tablename],
            'v'
        ) != '') {
            $o = ['useInsertUpdate' => true];
        }
        if (($result = $table->update($input, $o)) !== false) {
            if ($table->error()) {
                throw new Exception($table->errorMessage());
            }
            $warnings = $table->warnings();
            $moreResults = $table->moreResults();
            App::deferredTrigger();
            return [
                'success' => true,
                'warnings' => $warnings,
                'moreResults' => $moreResults,
                'result' => $result,
                'data' => DSRoutes::readWrittenRows($db, $tablename, $result),
            ];
        }
        throw new Exception($table->errorMessage() !== '' ? $table->errorMessage() : 'update failed');
    }

    private static function destroy($db, string $tablename, $input): array
    {
        if (is_null($input)) {
            throw new Exception('Error Processing Request', 1);
        }
        $db->tinyIntAsBoolean(true);
        $table = new DSTable($db, $tablename);
        if ($table->delete($input) !== false) {
            if ($table->error()) {
                throw new Exception($table->errorMessage());
            }
            App::deferredTrigger();
            return ['success' => true];
        }
        throw new Exception($table->errorMessage() !== '' ? $table->errorMessage() : 'delete failed');
    }
}
