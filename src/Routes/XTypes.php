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
                TualoApplication::result('data',  
                    $db->direct('
                    select classic_type id,concat(name," (",classic_type," - ",vendor,") ") name 
                    from view_tualo_form_fields 
                    having classic_type like {filter} 
                    order by name
                    ',
                        array('filter'=>'%'.(isset($_REQUEST['query'])?$_REQUEST['query']:'').'%')
                    )
                );
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
                TualoApplication::result('data',  
                    $db->direct('
                    select classic_type id,concat(name," (",classic_type," - ",vendor,") ") name 
                    from view_tualo_column_types 
                    having 
                        classic_type like {filter} 
                    order by name
                    ',
                        [
                            'filter'=>'%'.(isset($_REQUEST['query'])?$_REQUEST['query']:'').'%'
                        ]
                    )
                );
                TualoApplication::result('total',  0  );
              
            }catch(\Exception $e){
            
                TualoApplication::result('last_sql', $db->last_sql );
                TualoApplication::result('msg', $e->getMessage());
            }
            TualoApplication::contenttype('application/json');
        },['get','post'],true);            

    }
}
