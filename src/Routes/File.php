<?php
namespace Tualo\Office\DS\Routes;
use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route ;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSFileHelper;


class File implements IRoute{
    public static function register(){
        Route::add('/dsfile/mime',function(){

            $db = App::get('session')->getDB();
            try {
                
                $tablename = $_REQUEST['t'];
        
                if (isset($_REQUEST['id']) && ($tablename!='') ) {
                    $id = intval($_REQUEST['id']);
                    $result = DSFileHelper::getFileMimeType( $db,$tablename,$id );
                    foreach($result as $k=>$v){
                        App::result($k,$v);
                    }
                }
        
                
            }catch(Exception $e){
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        
        },array('get','post'),true);
    }
}