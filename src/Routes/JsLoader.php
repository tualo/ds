<?php
namespace Tualo\Office\DS\Routes;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route as BasicRoute;
use Tualo\Office\Basic\IRoute;

class JsLoader implements IRoute{
    public static function register(){
        BasicRoute::add('/jsds/(?P<file>[\w.\/\-]+).js',function($matches){

            if (file_exists(  dirname(__DIR__,1).'/js/lazy/'.$matches['file'].'.js' ) ){
                App::etagFile( dirname(__DIR__,1).'/js/lazy/'.$matches['file'].'.js' , true);
                BasicRoute::$finished = true;
                http_response_code(200);
            }
            
        },['get'],false);

    }
}