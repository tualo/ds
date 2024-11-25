<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;

class DSReadRoute{
    public static function readSingleItem($db,$tablename,$request){
        $res = self::read($db,$tablename,$request);
        if ($res['total']>=1){
            return $res['data']['0'];
        }
        return false;
    }
    
    public static function read($db,$tablename,$request){
        TualoApplication::deferredTrigger();
        $config = (TualoApplication::get('configuration'));
        if (!isset($request['shortfieldnames'])){ 
            $request['shortfieldnames']=1; $request['comibedfieldname']=0;
        }else{
            $request['comibedfieldname']=($request['shortfieldnames']==1)?0:1;
        }
        if (!isset($request['comibedfieldname'])) $request['comibedfieldname']=1;
        if (
            isset($request['filter']) &&
            !is_array($request['filter'])
        ){ 
            $request['filter']=json_decode($request['filter'],true); 
        }else if(!isset($request['filter'])){ 
            $request['filter']=[]; 
        }

        if (!isset($request['postprocessing'])) $request['postprocessing']=1;
        if (!isset($request['count'])) $request['count']=1;
        if (!isset($request['limit'])) $request['limit']=10;

        if (!isset($request['page'])) $request['page']=1;
        if ($request['page']<1)$request['page']=1;
        if ($request['limit']<1)$request['limit']=1;
        if (isset($request['start']) && ($request['start']<0))$request['start']=0;
        

        if (
            isset($request['sort']) &&
            !is_array($request['sort'])
        ){ 
            $request['sort']=json_decode($request['sort'],true); 
        }else if(!isset($request['sort'])){ 
            $request['sort']=[]; 
        }



        if (isset($request['reference'])) {
            $referenceobject= json_decode($request['reference'],true);
            foreach($referenceobject as $key=>$value){
                $request['filter'][] = [
                    'property'  => $key,
                    'operator'  => '=',
                    'value'     =>  $value
                ];
            }
        } 
        
        $request['tablename'] = $tablename;
        $request['nodata'] = 1;
        $request['fulltext'] = 0;

        TualoApplication::result('json_encode', ($request));
        $db->direct('set @request = {request};',['request'=>json_encode($request)]);
        $db->direct('call dsx_rest_api_get(@request,@result);');
        $mysqlresults = [];
        do {
            if ($result = $db->mysqli->use_result()) {
                $mysqlresults[] = $result->fetch_all(MYSQLI_ASSOC);
                $result->close();
            }
            if ($db->mysqli->more_results()) {
                $mysqlresults[] = '----------';
            }
        } while ($db->mysqli->next_result());
        // if (isset($config['__RETURN_DS_QUERY_PROCRESULTS__'])&&($config['__RETURN_DS_QUERY_PROCRESULTS__']==1)){
        if (true) {
            TualoApplication::result('m',$db->direct('select @request'));
            TualoApplication::result('mysqlresults',$mysqlresults);
        }

        $o = json_decode($db->singleValue('select @result res',[],'res'),true);
        if (isset($config['__LOGGER_DS_QUERY__'])&&($config['__LOGGER_DS_QUERY__']==1)){
            TualoApplication::logger('TualoApplication')->debug('DSReadRoute',[$o['query'].' '.$o['limitterm']]);
        }


        TualoApplication::result('sqlq',$o['query']);
        $o['data']=$db->direct($o['query'].' '.$o['order_by'].' '.$o['limitterm']);
        // TualoApplication::result('dsx_rest_api_get_result',$o['query']);

        if ($request['postprocessing']==1){
            $res = [];
            $row = ($request['page']*1-1)*$request['limit'] + 1;
            foreach($o['data'] as $elem){
                $res_elem=[];
                foreach($elem as $k=>$v){
                    if (in_array($k,['__table_name','__id','__displayfield'])){
                        $res_elem[ $k ] = $v;
                    }else if($request['comibedfieldname']==0){
                        $res_elem[$k] = $v;
                    }else{ 
                        $res_elem[$tablename.'__'.$k] = $v;
                    }
                }
                $res_elem['__rownumber']=$row++;
                $res[]=$res_elem;
            }
            $o['data']=$res;
        }
        if (is_null($o['total'])&&is_array($o['data'])) $o['total']=count($o['data']);
        return $o;
    
     }
}