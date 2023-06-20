<?php
namespace Tualo\Office\DS\Routes;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route ;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSTable;


class Import implements IRoute{

    /**
    * This function returns the maximum files size that can be uploaded 
    * in PHP
    * @returns int File size in bytes
    **/
    public static function getMaximumFileUploadSize()  
    {  
        return min(Import::convertPHPSizeToBytes(ini_get('post_max_size')), Import::convertPHPSizeToBytes(ini_get('upload_max_filesize')));  
    }  

    /**
    * This function transforms the php.ini notation for numbers (like '2M') to an integer (2*1024*1024 in this case)
    * 
    * @param string $sSize
    * @return integer The value in bytes
    */
    public static function convertPHPSizeToBytes($sSize)
    {
        //
        $sSuffix = strtoupper(substr($sSize, -1));
        if (!in_array($sSuffix,array('P','T','G','M','K'))){
            return (int)$sSize;  
        } 
        $iValue = substr($sSize, 0, -1);
        switch ($sSuffix) {
            case 'P':
                $iValue *= 1024;
                // Fallthrough intended
            case 'T':
                $iValue *= 1024;
                // Fallthrough intended
            case 'G':
                $iValue *= 1024;
                // Fallthrough intended
            case 'M':
                $iValue *= 1024;
                // Fallthrough intended
            case 'K':
                $iValue *= 1024;
                break;
        }
        return (int)$iValue;
    }     

    public static function register(){
        Route::add('/dsimport/maxfilesize',function($matches){
            App::result('success',true);
            App::result('size',Import::getMaximumFileUploadSize());
            
            App::contenttype('application/json');
        },['post','get'],true);
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
        },['post','get'],true);


        Route::add('/dsimport/check',function(){
            $db = App::get('session')->getDB();
            try{
                $result = [];
                $d = json_decode(file_get_contents( App::get('tempPath'). '/.ht_import_daten.cnf'), true);
                $result['d']=$d;
                if (isset($d)) {
                    if (isset($d['type'])) {
                        if (isset($d['name'])) {
                            if (isset($d['extension'])) {
                                $inputFileName = App::get('tempPath').'/.ht_import_daten.'.$d['extension'];
                                $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($inputFileName);
                                $sheets = $spreadsheet->getSheetNames();
                                $index=0;
                                foreach($sheets as $sheetName){
        
                                    $result['data'][] = array(
                                        'id' => $index,
                                        'name' => $sheetName
                                    );
                                    $index++;
                                }
                                App::result('success', true);
                                App::result('data',$result['data']);
                            }
        
        
                        }
                    }
                }
        
                
                 
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        
        },['get','post'],true);



        Route::add('/dsimport/extract',function(){

            $db = App::get('session')->getDB();
        
            try{
        
        
                $d = json_decode(file_get_contents( App::get('tempPath'). '/.ht_import_daten.cnf'), true);
                $result=[];
                $result['d']=$d;
        
                if (isset($d)) {
                    if (isset($d['type'])) {
                        $result['type']=$d['type'];
                        if (isset($d['name'])) {
                            if (isset($d['extension'])) {
                                $inputFileName = App::get('tempPath').'/.ht_import_daten.'.$d['extension'];
                                $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($inputFileName);
                                //$reader->setReadDataOnly(true);
                                $sheet = $spreadsheet->getSheet($_REQUEST['tbl']);
                                $result['count']=$sheet->getHighestDataRow();
                                $result['columnCount']=$sheet->getHighestColumn();
                                $result['success']=true;
        
                                $d['tbl']=$_REQUEST['tbl'];
                                $d['columnCount']=$result['columnCount'];
                                $d['count']=$result['count'];
                                $d['chunks']=array();
                                $d['chunksize']=200;
        
                                $chunk=0;
        
                                //\PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($result['columnCount'])
                                $d['header']=$sheet->rangeToArray(
                                    'A1:'.$result['columnCount'].'1',     // The worksheet range that we want to retrieve
                                    NULL,        // Value that should be returned for empty cells
                                    TRUE,        // Should formulas be calculated (the equivalent of getCalculatedValue() for each cell)
                                    TRUE,        // Should values be formatted (the equivalent of getFormattedValue() for each cell)
                                    TRUE         // Should the array be indexed by cell row and cell column
                                );
        
                                $index=2;
                                while($index<$d['count']+1){
                                    $stop = $index+$d['chunksize'];
                                    if ($stop>$d['count']){
                                        $stop = $d['count'];
                                    }
                                    $data = $sheet->rangeToArray(
                                        'A'.$index.':'.$result['columnCount'].($stop),     // The worksheet range that we want to retrieve
                                        NULL,        // Value that should be returned for empty cells
                                        TRUE,        // Should formulas be calculated (the equivalent of getCalculatedValue() for each cell)
                                        TRUE,        // Should values be formatted (the equivalent of getFormattedValue() for each cell)
                                        FALSE         // Should the array be indexed by cell row and cell column
                                    );
                                    $index+=$d['chunksize'];
                                    file_put_contents(App::get('tempPath').'/.ht_import_daten_'.$chunk.'.cnf',json_encode($data));
                                    $d['chunks'][]='.ht_import_daten_'.$chunk.'.cnf';
                                    $chunk++;
                                }
        
                                $result['count']--; // zero based!
                                $result['d']=$d;
                                file_put_contents(App::get('tempPath').'/.ht_import_daten.cnf',json_encode($d));
                                App::result('count', $result['count']);
                                App::result('columnCount', $result['columnCount']);
                                App::result('success', $result['success']);
                                App::result('d', $result['d']);
                                
                            }
                        }
                    }
                }
        
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        
        },['get','post'],true);
                

        

        Route::add('/dsimport/combo',function(){

            $db = App::get('session')->getDB();

            try{

                $result = [];
                $d = json_decode(file_get_contents( App::get('tempPath') . '/.ht_import_daten.cnf'), true);
                $result['d']=$d;
                //require_once TualoApplication::get('basePath').'/cmp/cmp_phpspreadsheet/vendor/autoload.php';
                
                
                if (isset($d)) {
                    if (isset($d['type'])) {
                        $result['type']=$d['type'];
                        if (isset($d['name'])) {
                            if (isset($d['extension'])) {
                                /*
                                $inputFileName = TualoApplication::get('tempPath').'/.ht_import_daten.'.$d['extension'];
                                $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($inputFileName);
                                //$reader->setReadDataOnly(true);
                                $sheet = $spreadsheet->getSheet($d['tbl']);
                                $result['count']=$sheet->getHighestDataRow();
                                */
                                $idx=0;
                                foreach($d['header'][1] as $hdr){
                                    $result['data'][] = array(
                                    'id' => "COLINDEX" . $idx,
                                    'name' => $hdr
                                    );
                                    $idx++;
                                }
                
                                $result['success']=true;
                            }
                        }
                    }
                }
                
                
                App::result('data',$result['data']);
                App::result('liste',$result['data']);
                App::result('success',$result['success']);
            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');

        },['get','post'],true);



        Route::add('/dsimport/source',function(){

            $db = App::get('session')->getDB();

            try{
                
                
                $result = ['data'=>[]];
                $d = json_decode(file_get_contents(App::get('tempPath') . '/.ht_import_daten.cnf'), true);
                $result['d']=$d;
                if (isset($d)) {
                    if (isset($d['type'])) {
                        $result['type']=$d['type'];
                        if (isset($d['name'])) {
                            if (isset($d['extension'])) {

                        
                        
                            
                                $dsconfig = [];
                                $dsconfig['ds_column']=$db->direct('select * from ds_column where table_name={t} and existsreal=1',$_REQUEST,'');
                                $dsconfig['ds_column_form_label']=$db->direct('select * from ds_column_form_label where table_name={t}',$_REQUEST,'');
                                $dsconfig['ds_column_list_label']=$db->direct('select * from ds_column_list_label where table_name={t}',$_REQUEST,'');

                                // $ds->getConfig(false,false); // not extended, do not clean the config
                                $spalten=array();
                                $txtspalten=array();
                                $viewtxtspalten=array();

                                // zumindest jede nicht null spalte muss importiert werden
                                foreach($dsconfig['ds_column'] as $v){
                                    if ($v['is_nullable']=='NO'){
                                        $spalten[$v['column_name']]=$v['default_value'];
                                    }
                                }

                                // jedes formularfeld sollte verfügbar sein
                                foreach($dsconfig['ds_column_form_label'] as $v){
                                //if (($v['hidden']=='0')&&($v['active']=='1')){
                                    $spalten[$v['column_name']]='';
                                    $txtspalten[strtolower($v['label'])]=$v['column_name'];
                                    $viewtxtspalten[$v['column_name']]=$v['field_path'].' '.$v['label'];
                                //}
                                }

                                // jedes formularfeld sollte verfügbar sein
                                foreach($dsconfig['ds_column_list_label'] as $v){
                                //if (($v['hidden']=='0')&&($v['active']=='1')){
                                    $spalten[$v['column_name']]='';
                                    $txtspalten[strtolower($v['label'])]=$v['column_name'];
                                    $viewtxtspalten[$v['column_name']]=$v['label'];
                                //}
                                }

                                foreach($dsconfig['ds_column'] as $v){
                                    if (isset($spalten[$v['column_name']])&&($v['default_value']!='')){
                                        $spalten[$v['column_name']]=$v['default_value'];
                                    }
                                }


                                $idx=0;
                                foreach($d['header'][1] as $d){
                                    if (is_null($d))$d='*NOT SET*';
                                    $val=strtolower($d);
                                    if (isset($txtspalten[$val])){
                                        $val = $txtspalten[$val];
                                    }
                                    if (isset($spalten[$val])){
                                        $spalten[$val]="COLINDEX".$idx;
                                    }
                                    $idx++;
                                }
                            
                                $daten=array();
                                foreach($spalten as $k=>$v){
                                    $daten[$k]=$v;
                                }

                                $xdaten=array();
                                foreach($daten as $k => $v){
                                    if (isset($txtspalten[$k])){
                                        $k = $txtspalten[$k];
                                    }
                                    $result['data'][]=array(
                                        'id'=> ($k),
                                        'text'=> (isset($viewtxtspalten[$k])?$viewtxtspalten[$k]:$k),//$spalten_config[$k]['list_label'],
                                        'position'=> 1,//$spalten_config[$k]['list_position'],
                                        'name'=> is_null($v)?"":$v,
                                        'dataindex'=>$k
                                    );
                                }
                                App::result('success',true);
                                App::result('list',$result['data']);
                            }
                        }
                    }
                }

            }catch(\Exception $e){
                App::result('last_sql', $db->last_sql );
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');

        },['get','post'],true);


        Route::add('/dsimport/import',function(){

            $db = App::get('session')->getDB();

            try{


                    $d = json_decode(file_get_contents(App::get('tempPath') . '/.ht_import_daten.cnf'), true);

                    if (!isset($_REQUEST['config'])) throw new \Exception('Config nicht gesetzt');
                    if (!isset($_REQUEST['index'])) throw new \Exception('Index nicht gesetzt');
                    if (!isset($_REQUEST['offset'])) throw new \Exception('Offset nicht gesetzt');
                    if (!isset($_REQUEST['t'])) throw new \Exception('Tabelle nicht gesetzt');
                    
                    $config = json_decode($_REQUEST['config'], true);
                    $offset = intval($_REQUEST['offset']);
                    $tablename = strtolower( $_REQUEST['t'] );
                    $columns = $db->direct('select * from ds_column where table_name={t} and existsreal=1',$_REQUEST,'column_name');
                    $_index = intval($_REQUEST['index']);        
                    $time = microtime(true);
                    $start_time = $time;
            

                
                    $max_time = intval(ini_get('max_execution_time'));
                    if ($max_time === false) $max_time = 60;

                    if (!is_numeric($max_time))  $max_time = 60; 
                    if ($_index < 10)  $max_time = 25; 

                    $max_time *= 0.5;
                    $max_time = 180;
                    $chunk = floor($_index/$d['chunksize']);
                    $data = json_decode(file_get_contents(App::get('tempPath') . '/.ht_import_daten_'.$chunk.'.cnf'), true);


                    $dataChunkForImport = $data ; //array_slice($data, $_index, $d['chunksize']);
                    $dataset = [];
                    foreach($dataChunkForImport as $data_row){
                        $dataRecord = [];
                        foreach ($config as $key => $value) {
                            if (strpos($value, 'COLINDEX') !== false) {
                                $fieldindex = intval(str_replace('COLINDEX', '', $value));
                                $dataset[$tablename.'__'.$key] = $data_row[$fieldindex];
                            } else {
                                if (($value != '') && ($value != '{#serial}')){
                                    $dataset[$tablename.'__'.$key] = $value;
                                }
                            }
                            if (isset($columns[$key]))
                            if ($columns[$key]['data_type']=='date'){
                                // if (isset($dataset[$tablename.'__'.$key])) $dataset[$tablename.'__'.$key] = makeISODate($dataset[$tablename.'__'.$key]);
                            }
                        }
                        $table = DSTable::init($db)->t($tablename);

                        $table->insert($dataRecord);
                        $_index++;
                    }
                    
                    // options replace ignore update
                    App::result('index',$_index);
                    App::result('count',$d['count']);
                    App::result('offset',$offset);
                    $table->readMoreResults();
                    $table->readWarnings();
                    App::result('warnings', $table->warnings());
                    App::result('moreResults', $table->moreResults());
                                    
                    App::result('tempPath',App::get('tempPath'));
                    App::result('chunk',$chunk);
                    
                    //App::result('dataset',$dataset);
                    App::result('success',true);
                }catch(\Exception $e){
                    App::result('last_sql', $db->last_sql );
                    App::result('msg', $e->getMessage());
                }
                App::contenttype('application/json');

            },['post'],true);

    }
}