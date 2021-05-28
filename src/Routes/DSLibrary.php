<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;


class DSLibrary implements IRoute{
    public static function register(){

        Route::add('/dslibrary/Routes.js',function($matches){
            try{
                if (file_exists(dirname(__DIR__).'/js/Routes.js')){  
                    TualoApplication::etagFile(dirname(__DIR__).'/js/Routes.js'); 
                    return;
                }else{
                    echo dirname(__DIR__).'/js/Routes.js';
                }
            }catch(\Exception $e){
        
            }
            TualoApplication::contenttype('application/javascript');
        },array('get'),false);


        Route::add('/dslibrary/all.js',function($matches){
            try{
                $session = TualoApplication::get('session');
                $db = TualoApplication::get('session')->getDB();
                if (!is_null($db)){
                    $db->direct('set @suppressRequires=1');
                    $data = $db->direct(
                        implode(' union ',[
                            'select js from view_ds_custom',
                            'select js from view_ds_model',
                            'select js from view_ds_store',
                            'select js from view_ds_column',
                            'select js from view_ds_displayfield',
                            'select js from view_ds_combobox',
                            'select js from view_ds_controller',
                            'select js from view_ds_list',
                            'select js from view_ds_form',
                            'select js from view_ds_dsview'
                        ])
                    );
                    foreach($data as $row){
                        TualoApplication::body( $row['js']."\n");
                    }
                }
            }catch(\Exception $e){
        
            }
            TualoApplication::contenttype('application/javascript');
        },array('get'),false);

        
    }
}