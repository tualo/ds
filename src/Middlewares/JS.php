<?php

namespace tualo\Office\DS\Middleware;
use tualo\Office\Basic\TualoApplication;
use tualo\Office\Basic\IMiddleware;

class JS implements IMiddleware{
    public static function register(){
        TualoApplication::use('ds_middleware',function(){
            try{
                
                TualoApplication::javascript('ds_middleware_routes', './dslibrary/Routes.js',[],0);
                TualoApplication::javascript('ds_middleware_custom', './dslibrary/all.js',[],0);
                
                //TualoApplication::javascript('ds_middleware_models', './dslibrrary/models.js',[],0);
                //TualoApplication::javascript('ds_middleware_stores', './dslibrrary/stores.js',[],0);
               
            }catch(\Exception $e){
                TualoApplication::set('maintanceMode','on');
                TualoApplication::addError($e->getMessage());
            }
        },-100); // should be one of the last
    }
}