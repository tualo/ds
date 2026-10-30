<?php

namespace Tualo\Office\DS\Routes\DS;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSTable;
use Tualo\Office\DS\Routes\DSBase;
use Tualo\Office\DS\Routes\DefaultExpectedFields;
use Tualo\Office\DS\Scopes\DSReadScope;
use Tualo\Office\DSX\Read\StreamResponse;


class Read extends DSBase
{
    public static function scope(): string
    {
        return DSReadScope::identifier();
    }

    public static function register()
    {

        Route::add('/ds/(?P<tablename>\w+)/read', function ($matches) {

            $startTime = microtime(true);
            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            try {
                $request = $_REQUEST;
                if (!isset($request['request_options'])) {
                    $request['request_options'] = [];
                }
                $request['tablename'] = $tablename;
                if (!isset($request['count'])) $request['count'] = 0;
                if (!isset($request['comibedfieldname'])) $request['comibedfieldname'] = 0;
                $db->direct('set @request_options = {request_options};', ['request_options' => json_encode($request['request_options'])]);

                StreamResponse::send($db, $request, fn() => ['execution_time' => microtime(true) - $startTime]);
                // response is sent, other routes for this path must not answer again
                return true;
            } catch (\Exception $e) {
                App::result('last_sql', $db->last_sql);
                App::result('msg', $e->getMessage());
            }
            $endTime = microtime(true);
            App::result('execution_time', $endTime - $startTime);
            App::contenttype('application/json');
        }, ['get', 'post'], true, [
            'errorOnUnexpected' => false,
            'errorOnInvalid' => false,
            'fields' => DefaultExpectedFields::$Fields
        ], self::scope());


        Route::add('/.ds/(?P<tablename>\w+)/read', function ($matches) {
            $startTime = microtime(true);
            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            ini_set('memory_limit', '8G');
            try {
                $db->tinyIntAsBoolean(true);
                self::setRequestParameter();
                $db->direct('SET SESSION group_concat_max_len = 4294967295;');

                $input = json_decode(file_get_contents('php://input'), true);
                if (is_null($input)) {
                    $input = $_REQUEST;
                }


                if (!isset($input['request_options'])) {
                    $input['request_options'] = [];
                }
                $db->direct('set @request_options = {request_options};', ['request_options' => json_encode($input['request_options'])]);


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

                // fields is allways expected to include __id
                /*if (isset($input['fields'])) {
                    if (is_string($input['fields'])) {
                        $input['fields'] = json_decode($input['fields'], true);
                        $input['fields'][] = '__id';
                        $input['fields'] = json_encode(array_unique($input['fields']));
                    }
                }*/
                $read = DSReadRoute::read($db, $tablename, $input);
                App::result('fields', $input);
                App::result('data', $read['data']);
                App::result('total', $read['total']);
                App::result('input', $input);

                App::result('scope', self::scope());



                App::result('success', true);
            } catch (\Exception $e) {
                App::result('success', false);
                App::logger('dstable')->error($e->getMessage(), [
                    'operation' => 'read',
                    'tablename' => $tablename,
                    'galera_hostname' => $db->singleValue('SELECT @@hostname v', [], 'v'),
                    'code' => $e->getCode(),
                ]);
                // App::result('last_sql', $db->last_sql);
                if ($e->getCode() == 15403) {
                    http_response_code(403);
                }
                App::result('code', $e->getCode());
                App::result('msg', $e->getMessage());
            }

            Route::$finished = true;
            $endTime = microtime(true);
            App::result('execution_time', $endTime - $startTime);
            App::contenttype('application/json');
        }, ['get', 'post'], true, [
            'errorOnUnexpected' => false,
            'errorOnInvalid' => false,
            'fields' => DefaultExpectedFields::$Fields
        ], self::scope());


        Route::add('/ds/(?P<tablename>\w+)/read/(?P<id>.+)', function ($matches) {
            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            ini_set('memory_limit', '8G');
            try {
                $db->tinyIntAsBoolean(true);
                self::setRequestParameter();
                $db->direct('SET SESSION group_concat_max_len = 4294967295;');
                // $db->direct( 'SET GLOBAL max_allowed_packet = 50331648 ' . (48 * 1024 * 1024) );
                //$read = DSReadRoute::read($db, $tablename, $_REQUEST);
                $table = new DSTable($db, $tablename);
                $read = $table->f('__id', 'eq', $matches['id'])->get();
                if ($table->error()) {
                    App::result('success', false);
                    App::result('msg', $table->errorMessage());
                    Route::$finished = true;
                    App::contenttype('application/json');
                    return;
                }


                App::result('data', $read);
                //App::result('total', $read['total']);
                App::result('success', true);
            } catch (\Exception $e) {
                App::result('success', false);
                App::result('code', $e->getCode());
                App::logger('dstable')->error($e->getMessage(), [
                    'operation' => 'read',
                    'tablename' => $tablename,
                    'code' => $e->getCode(),
                ]);
                App::result('msg', $e->getMessage());
                //App::result('dq', implode("\n",$GLOBALS['debug_query']));

            }

            Route::$finished = true;
            App::contenttype('application/json');
        }, ['get'], true, [], self::scope());
    }
}
