<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route ;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;


class Import implements IRoute{
    public static function register(){
        Route::add('/dsimport/upload',function($matches){

        });
        Route::add('/dsimport/extract',function($matches){

        });
        Route::add('/dsimport/source',function($matches){

        });
    }
}