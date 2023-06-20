<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route ;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;


class Import implements IRoute{
    public static function register(){
        Route::add('/dsimport/upload',function($matches){
            $db = App::get('session')->getDB();
            try{
                $success=false;
                if (!function_exists("error2txt")){
                    function error2txt($error){
                        switch($error){
                            case UPLOAD_ERR_INI_SIZE: return "UPLOAD_ERR_INI_SIZE: Die Datei ist zu gro&szlig"; break;
                            case UPLOAD_ERR_FORM_SIZE: return "UPLOAD_ERR_FORM_SIZE: Die Datei ist zu gro&szlig"; break;
                            case UPLOAD_ERR_PARTIAL: return "UPLOAD_ERR_PARTIAL: Die Datei wurde nur teilweise hochgeladen"; break;
                            case UPLOAD_ERR_NO_FILE: return "UPLOAD_ERR_NO_FILE: Es wurde keine Datei hochgeladen"; break;
                            case 0: return " "; break;
                            default: return "Unbekannter Fehler"; break;
                        }
        
                    }
                }
                $error="";
                if (isset($_FILES['userfile'])){
                    $sfile = $_FILES['userfile']['tmp_name'];
                    $name = $_FILES['userfile']['name'];
                    $extension = pathinfo($name, PATHINFO_EXTENSION);
                    $type = $_FILES['userfile']['type'];
                    $error = $_FILES['userfile']['error'];
                    if ($error == UPLOAD_ERR_OK){
                        if (file_exists(App::get('tempPath').'/.ht_import_daten.'.$extension)){
                            unlink(App::get('tempPath').'/.ht_import_daten.'.$extension);
                        }
                        move_uploaded_file($sfile, App::get('tempPath').'/.ht_import_daten.'.$extension);
                        file_put_contents(App::get('tempPath').'/.ht_import_daten.cnf',
                            json_encode(array(
                                'type'=>$type,
                                'name'=>$name,
                                'extension'=>$extension
                            ))
                        );
                        $success=true;
                    }
                }
                App::result('success',$success);
                App::result('data',[]);
                App::result('msg',error2txt($error));
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        });
        Route::add('/dsimport/extract',function($matches){

        });
        Route::add('/dsimport/source',function($matches){

        });
    }
}