<?php
namespace Tualo\Office\DS\Routes;
use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route ;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;


class DS implements IRoute{
    public static function register(){
        Route::add('/ds/(?P<tablename>\w+)/read',function($matches){
            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            
            try{
                $db->direct('SET SESSION group_concat_max_len = 4294967295;');
                $read = DSReadRoute::read($db,$tablename,$_REQUEST);
                App::result('data',$read['data']);
                App::result('total',$read['total']);
                App::result('success', true);
                
            }catch(\Exception $e){
        
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
                App::result('dq', implode("\n",$GLOBALS['debug_query']));
        
            }

            Route::$finished=true;
            App::contenttype('application/json');
        },array('get','post'),true);


        Route::add('/ds/(?P<tablename>\w+)/update',function($matches){
            App::contenttype('application/json');

            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            try{

                $input = json_decode(file_get_contents('php://input'),true);
                if (is_null( $input )) throw new Exception("Error Processing Request", 1);
                if (isset( $input['__id'] )){ 
                    $input = [$input];
                }


                foreach($input as $row){ 
                    $sql = $db->singleValue('select ds_serial({d}) s',['d'=>json_encode(['data'=>$row])],'s');
                    $db->execute($sql);
                    $sql = $db->singleValue('select ds_update({d}) s',['d'=>json_encode(['data'=>$row])],'s');
                    $db->execute($sql);
                }
                App::result('success', true);
                
            }catch(\Exception $e){
        
                App::result('msg', $e->getMessage());
        
            }
            Route::$finished=true;
        },array('post'),true);
   
        Route::add('/ds/(?P<tablename>\w+)/create',function($matches){
            App::contenttype('application/json');

            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            try{

                $input = json_decode(file_get_contents('php://input'),true);
                if (is_null( $input )) throw new Exception("Error Processing Request", 1);
                if (isset( $input['__id'] )){ 
                    $input = [$input];
                }


                foreach($input as $row){ 
                    $sql = $db->singleValue('select ds_serial({d}) s',['d'=>json_encode(['data'=>$row])],'s');
                    $db->execute($sql);
                    $sql = $db->singleValue('select ds_insert({d}) s',['d'=>json_encode(['data'=>$row])],'s');
                    App::result('debugsql', $sql);
                    $db->execute($sql);
                }
                App::result('success', true);
                
            }catch(\Exception $e){
        
                App::result('msg', $e->getMessage());
        
            }
            Route::$finished=true;
        },array('post'),true);
    }
};