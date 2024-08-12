<?php

namespace Tualo\Office\DS\Routes;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSTable;


class DS implements IRoute
{
    public static function register()
    {
        Route::add('/ds/(?P<tablename>\w+)/read', function ($matches) {
            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            ini_set('memory_limit', '8G');
            try {
                $db->direct('SET SESSION group_concat_max_len = 4294967295;');
                $read = DSReadRoute::read($db, $tablename, $_REQUEST);
                App::result('data', $read['data']);
                App::result('total', $read['total']);
                App::result('success', true);
            } catch (\Exception $e) {

                App::result('last_sql', $db->last_sql);
                App::result('msg', $e->getMessage());
                //App::result('dq', implode("\n",$GLOBALS['debug_query']));

            }

            Route::$finished = true;
            App::contenttype('application/json');
        }, ['get', 'post'], true);


        Route::add('/ds/(?P<tablename>\w+)/read/(?P<id>.+)', function ($matches) {
            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            ini_set('memory_limit', '8G');
            try {
                $db->direct('SET SESSION group_concat_max_len = 4294967295;');
                //$read = DSReadRoute::read($db, $tablename, $_REQUEST);
                $table = new DSTable($db, $tablename);
                $read = $table->f('__id','eq',$matches['id'])->read()->get();

                App::result('data', $read);
                //App::result('total', $read['total']);
                App::result('success', true);
            } catch (\Exception $e) {

                App::result('last_sql', $db->last_sql);
                App::result('msg', $e->getMessage());
                //App::result('dq', implode("\n",$GLOBALS['debug_query']));

            }

            Route::$finished = true;
            App::contenttype('application/json');
        }, ['get'], true);

        Route::add('/ds/(?P<tablename>\w+)/update', function ($matches) {
            App::contenttype('application/json');

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');
            $tablename = $matches['tablename'];
            $table = null;
            try {

                $input = json_decode(file_get_contents('php://input'), true);
                if (is_null($input)) throw new Exception("Error Processing Request", 1);
                $table = new DSTable($db, $tablename);
                $o = [];
                if ($db->singleValue('select ifnull(read_table,"") v from ds where table_name = {tablename} and use_insert_for_update=1', ['tablename' => $tablename],'v')!='') {
                    $o = [ 'useInsertUpdate'=>true];
                }
                if (($result = $table->update($input,$o)) !== false) {
                    if ($table->error()) {
                        throw new \Exception($table->errorMessage());
                    }
                    App::result('warnings', $table->warnings());
                    App::result('moreResults', $table->moreResults());
                    App::deferredTrigger();
                    if (isset($result['data'])) App::result('data', $table->prepareRecords($result['data']));
                    App::result('success', true);
                    App::result('result', $result);

                    $read = DSReadRoute::read($db, $tablename, [
                        'tablename' => $tablename,
                        'concat_set_table' => 1
                    ]);
                    App::result('data', $read['data']);

                    
                } else {
                    App::result('success', false);
                    App::result('warnings',  $db->getWarnings());

                    if (!is_null($table)) {

                        $table->readMoreResults();
                        $table->readWarnings();
                        App::result('warnings', $table->warnings());
                        App::result('moreResults', $table->moreResults());
                    }

                    App::result('msg', $table->errorMessage());
                }
            } catch (\Exception $e) {
                if (!is_null($table)) {
                    $table->readMoreResults();
                    $table->readWarnings();
                    App::result('warnings', $table->warnings());
                    App::result('moreResults', $table->moreResults());
                }
                App::result('msg', $e->getMessage());
            }
            Route::$finished = true;
        }, ['post'], true);

        Route::add('/ds/(?P<tablename>\w+)/create', function ($matches) {
            App::contenttype('application/json');

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');
            $tablename = $matches['tablename'];
            try {

                $input = json_decode(file_get_contents('php://input'), true);
                if (is_null($input)) throw new Exception("Error Processing Request", 1);
                $table = new DSTable($db, $tablename);
                if (($result = $table->insert($input)) !== false) {
                    if ($table->error()) {
                        throw new \Exception($table->errorMessage());
                    }

                    App::result('warnings', $table->warnings());
                    App::result('moreResults', $table->moreResults());
                    App::deferredTrigger();
                    if (isset($result['data'])) App::result('data', $table->prepareRecords($result['data']));
                    App::result('success', true);

                    $read = DSReadRoute::read($db, $tablename, [
                        'tablename' => $tablename,
                        'concat_set_table' => 1
                    ]);
                    App::result('data', $read['data']);

                } else {
                    App::result('success', false);
                    App::result('warnings', $table->warnings());
                    App::result('moreResults', $table->moreResults());
                    App::result('msg', $table->errorMessage());
                }
            } catch (\Exception $e) {

                App::result('msg', $e->getMessage());
            }
            Route::$finished = true;
        }, ['post'], true);


        Route::add('/ds/(?P<tablename>\w+)/delete', function ($matches) {
            App::contenttype('application/json');

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');
            $tablename = $matches['tablename'];
            try {

                $input = json_decode(file_get_contents('php://input'), true);
                if (is_null($input)) throw new Exception("Error Processing Request", 1);
                $table = new DSTable($db, $tablename);
                if ($table->delete($input) !== false) {
                    if ($table->error()) {
                        throw new \Exception($table->errorMessage());
                    }
                    App::deferredTrigger();
                    App::result('success', true);
                } else {
                    App::result('success', false);
                    App::result('msg', $table->errorMessage());
                }
            } catch (\Exception $e) {

                App::result('msg', $e->getMessage());
            }
            Route::$finished = true;
        }, ['post'], true);
    }
};
