<?php
namespace tualo\Office\DS\Routes;
use tualo\Office\Basic\TualoApplication as App;
use tualo\Office\Basic\Route as R;
use tualo\Office\Basic\IRoute;
use tualo\Office\DS\DS\DSReadRoute;


class DS implements IRoute{
    public static function register(){

        R::add('/ds/(?P<tablename>\w+)/read',function($matches){

            $db = App::get('session')->getDB();
            $tablename = $matches['tablename'];
            $db->direct('SET SESSION group_concat_max_len = 4294967295;');

            try{

                //try{
                    /*
                    $tables = $db->direct('select used_table_name from view_readtable_ds_used_tables where table_name={table_name} ',['table_name'=>$tablename]);
                    $checksum = false;
                    foreach($tables as $tn){
                        if (!($chk = $db->singleValue('CHECKSUM TABLE `'.$tn['used_table_name'].'`',[],'checksum'))){
                            if ($checksum===false) $checksum='';
                            $checksum.=$chk;
                        }
                    }
                    */
                    $checksum = $db->singleValue('CHECKSUM TABLE `'.$tablename.'`',[],'checksum');


                    if ($checksum!==false){
                        $request_checksum = md5(print_r($_REQUEST,true));
                        $etag = md5($checksum.$tablename.$request_checksum);
                        header('ETag: '.$etag);
                        header('Cache-Control: private,max-age=3000');
                        $headers = getallheaders();

                        if (isset($headers['If-None-Match']) && ($headers['If-None-Match']==$etag) ){
                            //HTTP/1.1 304 Not Modified
                            header("HTTP/1.1 304 Not Modified"); 
                            exit();
                        }

                    }
                    // }catch(\Exception $e){ }

                $GLOBALS['debug_query'] =array();
                $read = DSReadRoute::read($db,$tablename,$_REQUEST);
                App::result('data',$read['data']);
                App::result('total',$read['total']);
                App::result('success', true);
                
            }catch(Exception $e){
        
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
                App::result('dq', implode("\n",$GLOBALS['debug_query']));
        
            }
            App::contenttype('application/json');
        },array('get','post'),true);


        R::add('/ds/(?P<tablename>\w+)/update',function($matches){
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
                    $sql = $db->singleValue('select ds_update({d}) s',['d'=>json_encode(['data'=>$row])],'s');
                    $db->direct($sql);
                }
                App::result('success', true);
                
            }catch(Exception $e){
        
                App::result('msg', $e->getMessage());
        
            }
        },array('post'),true);
        
    }
};