<?php

namespace Tualo\Office\DS\Routes;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSExporterHelper;


class Export extends \Tualo\Office\Basic\RouteWrapper
{

    public static function filesystemName($string)
    {
        return preg_replace('/[^\w\-\.]/', '_', $string);
    }

    public static function register()
    {
        Route::add('/ds/(?P<tablename>\w+)/export', function ($matches) {
            $tablename = strtolower($matches['tablename']);
            $db = App::get('session')->getDB();

            ini_set('memory_limit', '16096M');

            $db->direct('SET SESSION group_concat_max_len = 4294967295;');
            try {

                $_REQUEST['start'] = 0;
                $_REQUEST['limit'] = 1650000;
                $hcolumns = DSExporterHelper::getExportColumns($db, $tablename);
                $temporary_folder = App::get("tempPath") . '/';
                if (isset($_REQUEST['usename']) && (strlen($_REQUEST['usename']) > 0)) {
                    $fname = self::filesystemName(basename($_REQUEST['usename']));
                } else {
                    $fname = '';
                }
                set_time_limit(300);
                $read = DSReadRoute::read($db, $tablename, $_REQUEST);

                DSExporterHelper::exportDataToXSLX($db, $tablename, $hcolumns, $read['data'], $temporary_folder, $fname, $hcolumns);
                App::result('file', $fname);
                App::result('success', true);
                //                App::result('read', $read);
                //                App::result('hcolumns', $hcolumns);


            } catch (\Exception $e) {
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['get', 'post'], true);
    }
}
