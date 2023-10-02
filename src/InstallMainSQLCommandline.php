<?php
namespace Tualo\Office\DS;
use Garden\Cli\Cli;
use Garden\Cli\Args;
use phpseclib3\Math\BigInteger\Engines\PHP;
use Tualo\Office\Basic\ICommandline;
use Tualo\Office\ExtJSCompiler\Helper;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\PostCheck;

class InstallMainSQLCommandline implements ICommandline{

    public static function getCommandName():string { return 'install-sql-ds';}

    public static function setup(Cli $cli){
        $cli->command(self::getCommandName())
            ->description('installs needed sql procedures for ds module')
            ->opt('client', 'only use this client', true, 'string');
            
    }

   
    public static function setupClients(string $msg,string $clientName,string $file,callable $callback){
        $_SERVER['REQUEST_URI']='';
        $_SERVER['REQUEST_METHOD']='none';
        App::run();

        $session = App::get('session');
        $sessiondb = $session->db;
        $dbs = $sessiondb->direct('select username dbuser, password dbpass, id dbname, host dbhost, port dbport from macc_clients ');
        foreach($dbs as $db){
            if (($clientName!='') && ($clientName!=$db['dbname'])){ 
                continue;
            }else{
                
                App::set('clientDB',$session->newDBByRow($db));
                PostCheck::formatPrint(['blue'],$msg.'('.$db['dbname'].'):  ');
                $callback($file);
                PostCheck::formatPrintLn(['green'],"\t".' done');

            }
        }
    }

    public static function run(Args $args){
        $files = [
            'main_compiler' => 'setup main compiler views ',
            'main_dsx' => 'setup main ds procedures ',
            'custom_types' => 'setup custom types ',
            'addcommand' => 'load addcommand ',
            'ds_files' => 'add ds files ',
            'ds_renderer_stylesheet_attributes_dd' => 'setup ds_renderer_stylesheet_attributes_dd  ',
            'ds_renderer_stylesheet_attributes_dd.ds' => 'setup ds_renderer_stylesheet_attributes_dd  ds ',
            'ds_listplugin'=> 'setup ds_listplugin ',
        ];

        foreach($files as $file=>$msg){
            $installSQL = function(string $file){

                $filename = __DIR__.'/sql/'.$file.'.sql';
                $sql = file_get_contents($filename);
                $sql = preg_replace('!/\*.*?\*/!s', '', $sql);
                $sql = preg_replace('#^\s*\-\-.+$#m', '', $sql);

                $sinlgeStatements = App::get('clientDB')->explode_by_delimiter($sql);
                foreach($sinlgeStatements as $commandIndex => $statement){
                    try{
                        App::get('session')->db->direct('select database()'); // keep connection alive
                        if ($file=='main_compiler'){
                            if (strpos($statement,'view_ds_dsview_accordion')!==false){
                                // PostCheck::formatPrintLn(['blue'], $statement .': commandIndex => '.$commandIndex);
                            }
                        } 
                        App::get('clientDB')->direct($statement);
                        App::get('clientDB')->moreResults();
                    }catch(\Exception $e){
                        echo PHP_EOL;
                        PostCheck::formatPrintLn(['red'], $e->getMessage().': commandIndex => '.$commandIndex);
                    }
                }
            };
            $clientName = $args->getOpt('client');
            if( is_null($clientName) ) $clientName = '';
            self::setupClients($msg,$clientName,$file,$installSQL);
        }



    }
}
