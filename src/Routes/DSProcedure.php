<?php

namespace Tualo\Office\DS\Routes;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSSetup;


class DSProcedure extends \Tualo\Office\Basic\RouteWrapper
{
    public static function scope(): string
    {
        return 'ds.procedures';
    }
    public static function register()
    {

        Route::add('/dsrun/(?P<proc>[\w\_\-]+)', function ($matches) {

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try {
                if (isset($_REQUEST['list'])) {
                    $list = json_decode($_REQUEST['list'], true);
                    $proc = $matches['proc'];
                    $msgs = [];
                    $results = [];
                    $warnings = [];
                    foreach ($list as $id) {
                        set_time_limit(600);
                        $db->direct('call ' . $proc . '({id},@result,@msg)', ['id' => $id]);
                        $results    = array_merge($results, $db->moreResults());
                        $warnings   = array_merge($warnings, $db->getWarnings());

                        $r = $db->direct('select @result result,@msg msg');
                        if ($r[0]['result'] == 1) {
                            $msgs[] = $r[0]['msg'];
                        } else {
                            throw new \Exception($r[0]['msg'], 1);
                            break;
                        }
                    }
                }
                App::result('success', true);
                App::result('results', $results);
            } catch (\Exception $e) {
                App::result('last_sql', $db->last_sql);
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['post'], true, [], self::scope());




        Route::add('/dsrun/(?P<proc>[\w\_\-]+)/(?P<id>[\w\_\-]+)', function ($matches) {

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try {
                $proc = $matches['proc'];
                $msgs = [];
                $results = [];
                $warnings = [];
                set_time_limit(600);
                $db->direct('call ' . $proc . '({id},@result,@msg)', ['id' => $matches['id']]);
                $results    = array_merge($results, $db->moreResults());
                $warnings   = array_merge($warnings, $db->getWarnings());

                $r = $db->direct('select @result result,@msg msg');
                if ($r[0]['result'] == 1) {
                    $msgs[] = $r[0]['msg'];
                } else {
                    throw new \Exception($r[0]['msg'], 1);
                }
                App::result('success', true);
                App::result('results', $results);
            } catch (\Exception $e) {
                // App::result('last_sql', $db->last_sql);
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['get'], true, [], self::scope());


        Route::add('/procedure/(?P<proc>[\w\_\-]+)', function ($matches) {

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try {
                $proc = $matches['proc'];
                $results = [];
                $warnings = [];
                $db->direct('call ' . $proc . '()', []);
                $results    = array_merge($results, $db->moreResults());
                $warnings   = array_merge($warnings, $db->getWarnings());

                App::result('success', true);
                App::result('results', $results);
            } catch (\Exception $e) {
                App::result('last_sql', $db->last_sql);
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['get'], true, [], self::scope());
    }
}
