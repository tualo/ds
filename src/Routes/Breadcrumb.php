<?php

namespace Tualo\Office\DS\Routes;

use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;


class Breadcrumb extends \Tualo\Office\Basic\RouteWrapper
{
    public static function register()
    {
        Route::add('/breadcrumb/menu', function () {

            $db = TualoApplication::get('session')->db;
            try {
                $menu = [];
                $menu[] = [
                    "text" => "R",
                    "expanded" => "true",
                    "children" => [
                        [
                            "text" => "X",
                            "children" => [
                                ["leaf" => "true", "text" => "A"]
                            ]
                        ]
                    ]
                ];

                /*$menu='
                    [{
                        "text": "R",
                        "expanded": "true",
                        "children": [
                        {
                            "text": "X",
                            "children": [
                                { "leaf": "true", "text": "A" }
                            ]
                        }
                    }]
                ';
                echo json_encode(json_decode($menu,true));
                */
                echo json_encode($menu);
                exit();
            } catch (\Exception $e) {
                TualoApplication::result('msg', $e->getMessage());
            }
        }, array('get', 'post'), false);
    }
}
