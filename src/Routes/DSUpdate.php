<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route ;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSExporterHelper;


class DSUpdate implements IRoute{
    public static function register(){
        Route::add('/dssetup/ds-update',function($matches){

        $db = App::get('session')->getDB();
        $db->direct('SET SESSION group_concat_max_len = 4294967295;');

        try{
            $db->direct('call UPDATE_DS_SETUP()');
            App::result('success', true);
        }catch(\Exception $e){
            App::result('last_sql', $db->last_sql );
            App::result('msg', $e->getMessage());
        }
        App::contenttype('application/json');
        },['get','post'],true);



        Route::add('/dsrun/(?P<proc>[\w\_\-]+)',function($matches){

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try{
                if (isset($_REQUEST['list'])){
                    $list = json_decode($_REQUEST['list'],true);
                    $proc = $_REQUEST['proc'];
                    $msgs = [];
                    foreach ($list as $id) {
                        set_time_limit(600);
                        $db->direct('call '.$proc.'({id},@result,@msg)',['id'=>$id]);
                        $r = $db->direct('select @result result,@msg msg');
                        if ($r[0]['result']==1){
                            $msgs[]=$r[0]['msg'];
                        }else{
                            throw new \Exception($r[0]['msg'],1);
                            break;
                        }
                    }
                }
                App::result('success', true);
                App::result('r',$_REQUEST);
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        },['post'],true);



        Route::add('/dssetup/ds_cloneformlabelexport',function($matches){

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try{
                //$db->direct('call UPDATE_DS_SETUP()');
                App::result('success', true);
                App::result('r',$_REQUEST);
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        },['get','post'],true);
        
    }
} 