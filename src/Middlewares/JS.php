<?php

namespace Tualo\Office\DS\Middlewares;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\IMiddleware;

class JS implements IMiddleware{
    public static function register(){
        TualoApplication::use('ds_middleware',function(){
            try{
                
                //TualoApplication::javascript('ds_middleware_routes', './dslibrary/Routes.js',[],0);
                //TualoApplication::javascript('ds_middleware_custom', './dslibrary/all.js',[],0);

                /*
                if ($matches['file']=='model') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_model" m from view_ds_model limit 2000 ' ));
                if ($matches['file']=='store') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_store" m from view_ds_store limit 2000 ' ));
                if ($matches['file']=='column') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_column" m from view_ds_column limit 2000  '));
                if ($matches['file']=='combobx') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_combobox" m from view_ds_combobox limit 2000 '));
                if ($matches['file']=='displayfield') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_displayfield" m from view_ds_displayfield  2imit 1000 '));
                if ($matches['file']=='controller') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_controller" m from view_ds_controller 2imit 1000 '));
                if ($matches['file']=='list')  $data = array_merge($data,$db->direct('select js,table_name,"view_ds_list" m from view_ds_list limit 2000 '));
                if ($matches['file']=='form') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_form" m from view_ds_form limit 2000 '));
                if ($matches['file']=='dsview') $data = array_merge($data,$db->direct('select js,table_name,"view_ds_dsview" m from view_ds_dsview limit 2000  '));
                */
                //TualoApplication::javascript('ds_middleware_models', './dslibrary/model.js',[],0);
                //TualoApplication::javascript('ds_middleware_stores', './dslibrary/store.js',[],0);
                //TualoApplication::javascript('ds_middleware_column', './dslibrary/column.js',[],0);
                // TualoApplication::javascript('ds_middleware_list', './dslibrary/list.js',[],0);
                
                //TualoApplication::javascript('ds_middleware_models', './dslibrrary/models.js',[],0);
                //TualoApplication::javascript('ds_middleware_stores', './dslibrrary/stores.js',[],0);
               
            }catch(\Exception $e){
                TualoApplication::set('maintanceMode','on');
                TualoApplication::addError($e->getMessage());
            }
        },-100); // should be one of the last
    }
}