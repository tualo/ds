<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;


class JS implements IRoute{
    public static function register(){

        

        Route::add('/Tualo/cmp/cmp_ds/(?P<file>[\/.\w\d]+)',function($matches){
            if (file_exists(dirname(__DIR__).'/js/'.$matches['file'])){
                TualoApplication::etagFile((dirname(__DIR__).'/js/'.$matches['file']));
                TualoApplication::contenttype('application/javascript');
                Route::$finished=true;
            }
        },array('get'),false);
        
        
        Route::add('/Tualo/DataSets/(?P<type>[\/.\w\d\_]+)/(?P<tablename>[\/.\w\d\_]+)/(?P<name>[\/.\w\d\_]+).js',function($matches){
            try{
                $session = TualoApplication::get('session');
                $db = TualoApplication::get('session')->getDB();
                TualoApplication::result('msg','');
                TualoApplication::result('success',false);
                TualoApplication::contenttype('text/javascript');
        
                if (file_exists(dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js')){  
                    TualoApplication::etagFile((dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js')); 
                    Route::$finished=true;
                    return;
                }
        
                if (file_exists(dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js')){
                    TualoApplication::etagFile(dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js');
                }
                
        
                if (
                        isset($_SESSION['tualoapplication']['loggedIn'])
                    &&  ($_SESSION['tualoapplication']['loggedIn']===true)
                    &&  (!is_null($session))
                    &&  (!is_null($db))
                ){
                    $v=false;
        
                    
                    if ($matches['type']=='column') $v = $db->singleValue('select js from view_ds_column where table_name=lower({tablename}) and name=lower({name}) ',$matches,'js');
                    if ($matches['type']=='combobox') $v = $db->singleValue('select js from view_ds_combobox where table_name=lower({tablename}) and name=lower({name}) ',$matches,'js');
                    if ($matches['type']=='displayfield') $v = $db->singleValue('select js from view_ds_displayfield where table_name=lower({tablename}) and name=lower({name}) ',$matches,'js');

                    if ($v!==false){
                        TualoApplication::body($v);
                    }
                }

                Route::$finished=true;

            }catch(\Exception $e){
//                echo $e->getMessage();
            }
        },array('get'),false);


        Route::add('/Tualo/DataSets/(?P<type>[\/.\w\d\_]+)/(?P<tablename>[\/.\w\d\_]+).js',function($matches){
            try{
                $session = TualoApplication::get('session');
                $db = TualoApplication::get('session')->getDB();
                TualoApplication::result('msg','');
                TualoApplication::result('success',false);
                TualoApplication::contenttype('text/javascript');
                
        
                if (file_exists(dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js')){  
                    TualoApplication::etagFile((dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js')); 
                    return;
                }
        
                if (file_exists(dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js')){
                    TualoApplication::etagFile(dirname(__DIR__).'/js/'.$matches['type'].'/'.$matches['tablename'].'.js');
                }
                
        
                if (
                        isset($_SESSION['tualoapplication']['loggedIn'])
                    &&  ($_SESSION['tualoapplication']['loggedIn']===true)
                    &&  (!is_null($session))
                    &&  (!is_null($db))
                ){
                    $v=false;

                    if ($matches['type']=='store') $v = $db->singleValue('select js from view_ds_store where table_name=lower({tablename}) ',$matches,'js');
                    if ($matches['type']=='model') $v = $db->singleValue('select js from view_ds_model where table_name=lower({tablename}) ',$matches,'js');
                    
                    if ($matches['type']=='list'){
                         $v = $db->singleValue('select js from view_ds_list where table_name=lower({tablename}) ',$matches,'js');
                    }
                    if ($matches['type']=='form') $v = $db->singleValue('select js from view_ds_form where table_name=lower({tablename}) ',$matches,'js');
                    if ($matches['type']=='dsview') $v = $db->singleValue('select js from view_ds_dsview where table_name=lower({tablename}) ',$matches,'js');
                    if ($matches['type']=='controller') $v = $db->singleValue('select js from view_ds_controller where table_name=lower({tablename}) ',$matches,'js');

                    /*
                    if ($matches['type']=='views') $v = $db->singleValue('select getViewport({tablename}) v',$matches,'v');
                    if ($matches['type']=='list') $v = $db->singleValue('select getListViewport({tablename}) v',$matches,'v');
                    if ($matches['type']=='stores') $v = $db->singleValue('select getStoreDefinition({tablename}) v',$matches,'v');
                    if ($matches['type']=='models') $v = $db->singleValue('select getViewportModel({tablename}) v',$matches,'v');
                    // if ($matches['type']=='model') $v = $db->singleValue('select getModelDefinition({tablename}) v',$matches,'v');
                    */
                    if ($v!==false){
                        TualoApplication::body($v);
                    }
                }
                Route::$finished=true;
            }catch(\Exception $e){
        
            }
        },array('get'),false);
        
        
        Route::add('/Tualo/DataSets/Viewport',function($matches){
            $matches=['file'=>'Viewport'];
            if (file_exists(dirname(__DIR__).'/js/'.$matches['file'])){  TualoApplication::etagFile((dirname(__DIR__).'/js/'.$matches['file'])); }
            TualoApplication::contenttype('application/javascript');
            Route::$finished=true;
        
        });
        
        
        Route::add('/Tualo/DataSets/store/Basic',function($matches){
            $matches=['file'=>'Viewport'];
            if (file_exists(dirname(__DIR__).'/js/'.$matches['file'])){  TualoApplication::etagFile((dirname(__DIR__).'/js/'.$matches['file'])); }
            TualoApplication::contenttype('application/javascript');
            Route::$finished=true;
        
        });
    }
}