<?php

namespace Tualo\Office\DS\Middlewares;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\IMiddleware;

class CSS implements IMiddleware{
    public static function register(){
        TualoApplication::use('ds_css_middleware',function(){
            try{
                TualoApplication::stylesheet("./dsstyle/shake.css" ,100000);
                TualoApplication::stylesheet("./dsstyle/row-colors.css" ,100000);
                TualoApplication::stylesheet("./dsstyle/font-colors.css" ,100000);
            }catch(\Exception $e){
                TualoApplication::set('maintanceMode','on');
                TualoApplication::addError($e->getMessage());
            }
        },-100); // should be one of the last
    }
}