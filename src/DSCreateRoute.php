<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;

class DSCreateRoute{

        
        
public static function initDSTrigger($db,$tablename){
    $triggers = array();
    try{
      $triggerlist = $db->direct('select program from `ds_trigger` where table_name={table_name}',array('table_name'=>$tablename));
      foreach ($triggerlist as $row) {
        $triggers[] = TualoApplication::get('basePath').'/cmp/'.$row['program'];
      }
    }catch(\Exception $e){
      echo $e->getMessage();
    }
    return $triggers;
}



public static function createRecord($db,$tablename,$request,$request_record){


    $sql = $db->singleValue('select ds_insert({record}) x',['record'=>json_encode(['data'=>$request_record])],'x');
   

    $queryparams = array(
        'table_name'=>$tablename,
        'query_type'=>'append',
        'query_start'=> (isset($request['start']))?intval($request['start']):0,
        'query_limit'=> (isset($request['limit']))?intval($request['limit']):100
    );

    $updateOnDuplicate = isset($request['updateOnDuplicate'])&&($request['updateOnDuplicate']=='1');

    DSRoutesHelper::initQuery($db,$tablename,$queryparams,$request);
    DSRoutesHelper::setSort($db,$tablename,$queryparams,$request);

    DSRoutesHelper::filterObject($db,$tablename,$queryparams,$request);

    foreach($request_record as $key=>$value){
        if( (!is_null($value)) ){
            if (is_bool($value)){
                if ($value===false){
                    $value='0';
                }
                if ($value===true){
                    $value='1';
                }
            }
            if (strpos($key,'__')>0){
                if (is_array($value)){
                    $value = json_encode($value);
                }
                $db->direct( 'call addDSQueryValueByFieldName(@queryid,{property},{value})', array('property'=>$key,'value'=>$value) );
                TualoApplication::debug( $db->last_sql );
            }
        }
    }


    $db->direct( 'call calculateDSQueryDefaults(@queryid)', array() );
    TualoApplication::debug( $db->last_sql );




    $s = '';
    if ($updateOnDuplicate){
        $s =  $db->singleValue('select getDSInsert(@queryid,true) s',array(),'s');
    }else{
        $s =  $db->singleValue('select getDSInsert(@queryid,false) s',array(),'s');
    }
    TualoApplication::debug( $db->last_sql );

    $db->execute( $s );
    TualoApplication::debug( $db->last_sql );
    

    $result_record=array();
//            $s =  $db->singleValue('select concat( getDSRead(@queryid,false,false) ,\' having \',getDSPrimaryKeyValueFilter( @queryid, \'__\' )) s', array() ,'s');
    
    $result_record_sql =  $db->singleValue('select concat( \'select * from (\',getDSRead(@queryid,false,false) ,\') SUBX having \',getDSPrimaryKeyValueFilter( @queryid, \'__\' )) s', array() ,'s');
    TualoApplication::result( 'debugSQLResult',$s);

    $result_record =  $db->singleRow( $result_record_sql , array());
    TualoApplication::debug( $db->last_sql );
    


    
    if ($r = $db->singleRow('show procedure status where db=database() and name=\'dstrigger__'.$tablename.'\'')){
        $db->direct('call dstrigger__'.$tablename.'(@queryid)',$queryparams); 
        $queries[] = $db->last_sql;
    }


    /*$triggers = self::initDSTrigger($db,$tablename);
    foreach ($triggers as $trigger_file) {
        if (file_exists($trigger_file)){
            include $trigger_file;

            if (class_exists($tablename.'_trigger')){
                $r = new \ReflectionClass($tablename.'_trigger');
                $triggerInstance = $r->newInstance(TualoApplication::get('session'));
                if ($triggerInstance->insert($result_record)===false){
                    throw new \Exception ($triggerInstance->lastlog());
                }
                $result_record['__debug_trigger'][$trigger_file]=$trigger->log();

            }else if (class_exists(substr(basename($trigger_file),0,-4))){
                $r = new \ReflectionClass(substr(basename($trigger_file),0,-4));
                $trigger = $r->newInstance(TualoApplication::get('session'));
                if ($trigger->insert($result_record)===false){

                }
                $result_record['__debug_trigger'][$trigger_file]=$trigger->log();
            }
        }
    }*/
    if (is_null($result_record)){
        $result_record =  $db->singleRow( $result_record_sql , array());
        TualoApplication::debug( $db->last_sql );
    }

    $db->direct('call cleanDSQuery(@queryid)',$queryparams); 
    $queries[] = $db->last_sql;


    return $result_record;
}

public static function createRequest($db,$tablename,$request){
    $result = array();
    if (!isset($request['data'])){
        $request['data'] = array($request);
    }
    if (isset($request['data']['__id'])){
        $singleRecord = true;
        $request_list = array($request['data']);
    }else{
        $request_list = $request['data'];
    }
    $data=array();
    if (count($request_list)>1000){
        $s =  $db->singleValue('select getBulkInsertSQL({table_name}) s', array('table_name'=>$tablename) ,'s');
        $db->execute_with_bulkhash($s,$request_list,false);
    }else{
        foreach($request_list as $request_record){
            $data[] = self::createRecord($db,$tablename,$request,$request_record);
        }
    }
    $result['data'] = $data;
    return $result;
}
}