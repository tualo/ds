<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;


class CSS implements IRoute{
    public static function register(){

        

        Route::add('/dsstyle/shake.css',function($matches){
            $path = dirname(dirname(__DIR__)).'';
            TualoApplication::contenttype('text/css');
            TualoApplication::etagFile( $path."/src/css/shake.css");
        },array('get','post'),false);

        Route::add('/dsstyle/row-colors.css',function($matches){
            $path = dirname(dirname(__DIR__)).'';
            TualoApplication::contenttype('text/css');
            TualoApplication::etagFile( $path."/src/css/row-colors.css");
        },array('get','post'),false);
    }
}