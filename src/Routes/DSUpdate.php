<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route ;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSSetup;


class DSUpdate implements IRoute{
    public static function register(){
        Route::add('/dssetup/ds-update',function($matches){

        $db = App::get('session')->getDB();
        $db->direct('SET SESSION group_concat_max_len = 4294967295;');

        try{
            
            $db->direct('call fill_ds("")');
            $mr = $db->moreResults();
            $wrn = $db->getWarnings();

            $db->direct('call fill_ds_column("")');
            $mr = [... $db->moreResults()];
            $wrn = [... $db->getWarnings()];

            App::result('mr', $mr);
            App::result('wrn', $wrn);
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
                    $proc = $matches['proc'];
                    $msgs = [];
                    $results=[];
                    $warnings=[];
                    foreach ($list as $id) {
                        set_time_limit(600);
                        $db->direct('call '.$proc.'({id},@result,@msg)',['id'=>$id]);
                        $results    = array_merge($results,$db->moreResults());
                        $warnings   = array_merge($warnings,$db->getWarnings());
                        
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
                App::result('results',$results);
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        },['post'],true);




        Route::add('/procedure/(?P<proc>[\w\_\-]+)',function($matches){

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try{
                $proc = $matches['proc'];
                $results=[];
                $warnings=[];
                $db->direct('call '.$proc.'()',[]);
                $results    = array_merge($results,$db->moreResults());
                $warnings   = array_merge($warnings,$db->getWarnings());
                
                App::result('success', true);
                App::result('results',$results);
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        },['get'],true);


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


        Route::add('/dssetup/export/definition/(?P<table_name>[\w\_\-]+)',function($matches){

            $db = App::get('session')->getDB();
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try{

                //$db->direct('call UPDATE_DS_SETUP()');
                App::result('success', true);
                $temporary_folder = App::get("tempPath") . '/';
                $fname =$matches['table_name'].'.ds.sql';
                $data=(new DSSetup($db,$matches['table_name']))->export();
                $data = array_merge(['DELIMITER;','SET FOREIGN_KEY_CHECKS=0;'], $data, ['SET FOREIGN_KEY_CHECKS=1;']);
                file_put_contents($temporary_folder.$fname,implode("\n",$data));
                App::result('file',$fname);
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        },['get','post'],true);
        
    }
} 