<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;


class XTypes implements IRoute{
    public static function register(){

        Route::add('/dslib/form/xtypes',function($matches){

            $db = TualoApplication::get('session')->getDB();
            try{ 
                    
                TualoApplication::result('success',  true  );
                TualoApplication::result('data',  []  );
                TualoApplication::result('total',  0  );
              
            }catch(\Exception $e){
            
                TualoApplication::result('last_sql', $db->last_sql );
                TualoApplication::result('msg', $e->getMessage());
            }
            TualoApplication::contenttype('application/json');
        },['get','post'],true);

        Route::add('/dslib/column/xtypes',function($matches){
            /*
            view_tualo_form_fields
            view_tualo_column_types
            */
            $db = TualoApplication::get('session')->getDB();
            try{ 
                    
                TualoApplication::result('success',  true  );
                TualoApplication::result('data',  []  );
                TualoApplication::result('total',  0  );
              
            }catch(\Exception $e){
            
                TualoApplication::result('last_sql', $db->last_sql );
                TualoApplication::result('msg', $e->getMessage());
            }
            TualoApplication::contenttype('application/json');
        },['get','post'],true);            

    }
}
