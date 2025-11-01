<?php

namespace Tualo\Office\DS\Routes;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSFileHelper;


class File extends \Tualo\Office\Basic\RouteWrapper
{
    public static function scope(): string
    {
        return 'ds.file';
    }
    public static function register()
    {

        Route::add(
            '/dsfile/download',
            function () {

                $db = App::get('session')->getDB();
                $session = App::get('session');
                try {

                    $tablename = $_REQUEST['t'];
                    $id = intval($_REQUEST['id']);
                    $direct = false;
                    $base64 = false;
                    $maxwidth = -1;
                    $maxheight = -1;
                    $result = DSFileHelper::getFile($db, $tablename, $id, $direct, $base64, $maxwidth, $maxheight);
                    foreach ($result as $k => $v) {
                        App::result($k, $v);
                    }
                } catch (\Exception $e) {
                    App::result('msg', $e->getMessage());
                }
                App::contenttype('application/json');
            },
            array('get', 'post'),
            true,
            [
                'errorOnUnexpected' => true,
                'errorOnInvalid' => true,
                'fields' =>
                [
                    't' => [
                        'required' => true,
                        'type' => 'string',
                        'max_length' => 128,
                        'pattern' => '/^[0-9a-zA-ZäöüÄÖÜß\s\-]+$/u',  // nur Buchstaben, Ziffern, Leerzeichen, Bindestriche
                        'min' => 0,
                        'max' => 10000000
                    ],
                    'id' => [
                        'required' => true,
                        'type' => 'integer',
                        'min' => 0,
                        'max' => 1000000000
                    ]
                ]
            ],
            self::scope()
        );

        Route::add('/dsfile/upload', function () {
            DSFileHelper::uploadRoute($tablename = $_REQUEST['t']);
        }, array('get', 'post'), true, [], self::scope());

        Route::add('/dsfile/(?P<tablename>[\w\-\_\|]+)/upload', function ($matches) {
            DSFileHelper::uploadRoute($tablename = $matches['tablename']);
        }, ['post'], true, [], self::scope());

        Route::add('/dsfile/mime', function () {

            $db = App::get('session')->getDB();
            try {

                $tablename = $_REQUEST['t'];

                if (isset($_REQUEST['id']) && ($tablename != '')) {
                    $id = intval($_REQUEST['id']);
                    $result = DSFileHelper::getFileMimeType($db, $tablename, $id);
                    foreach ($result as $k => $v) {
                        App::result($k, $v);
                    }
                }
            } catch (Exception $e) {
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, array('get', 'post'), true, [
            'errorOnUnexpected' => true,
            'errorOnInvalid' => true,
            'fields' =>
            [
                't' => [
                    'required' => true,
                    'type' => 'string',
                    'max_length' => 128,
                    'pattern' => '/^[0-9a-zA-ZäöüÄÖÜß\s\-]+$/u',  // nur Buchstaben, Ziffern, Leerzeichen, Bindestriche
                    'min' => 0,
                    'max' => 10000000
                ],
                'id' => [
                    'required' => true,
                    'type' => 'integer',
                    'min' => 0,
                    'max' => 1000000000
                ]
            ]
        ], self::scope());
    }
}
