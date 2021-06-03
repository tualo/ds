<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;


class CSS implements IRoute{
    public static function register(){

        

        Route::add('/dssytle/shake.css',function($matches){
            $path = dirname(dirname(__DIR__)).'';
            $data = file_get_contents( $path."/src/css/shake.css" );
            TualoApplication::body( $data );
            TualoApplication::contenttype('text/css');
        },array('get','post'),false);
    }
}