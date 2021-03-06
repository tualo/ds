<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;

class DSReadRoute{

    public static function getFilterValuesHashed($db, $queryparams ,$arrayOnly=false){
        $hash = [];
        $index =0;
        foreach($queryparams['filter'] as $entry){
            if (is_array( $entry['value'] ) ){
                $l = [];
                foreach($entry['value'] as $itm){
                    $l[] = '"'.$db->escape_string($itm).'"';
                }
                $entry['value'] = '('.implode(',', $l ).')';
                $hash['filter_list_'.$index]=$entry['value'];

            }else{
                if ($arrayOnly==false){
                    if (!is_string($entry['value'])&&!is_numeric($entry['value'])&&!is_null($entry['value'])){
                        throw new \Exception( "invalid type on *".$entry['property']."* (".gettype($entry['value']).")");
                    }
                    $hash['filter_'.$index]=$entry['value'];
                    if ($entry['operator']=='like'){
                        $hash['filter_'.$index]='%'.$entry['value'].'%';
                    }
                }
            }
            $index++;
        }
        return $hash;
    }

    public static function qhash($qp){
        $hash = $qp;
        if (isset($hash['search'])) unset($hash['search']);
        if (isset($hash['filter'])) unset($hash['filter']);
        $hash['filter']='';
        foreach($qp['filter'] as $elm){
            $hash['filter'].=$elm['property'].'-'.$elm['operator'];
        }
        return sha1(json_encode($hash));
    }

    public static function read($db,$tablename,$request){
        $time_start=microtime(true); 

        TualoApplication::timing("ds read start ".$tablename,'');
        /*
        if ($r = $db->singleRow('show procedure status where db=database() and name=\'dsreadtrigger__'.$tablename.'\'')){
            $db->direct('call dsreadtrigger__'.$tablename.'()'); 
        }
        */

        /*
        SELECT
            concat(
                rownumber,', ',
                displayfield,', ',
                idfield,', ',
                quote(ds_column.table_name),' AS __table_name, ',

                
                group_concat( 
                    concat(
                        ds_column.table_name,'.',ds_column.column_name,
                        if(comibedfieldname=1,concat(' AS `',ds_column.table_name,'__',ds_column.column_name,'`'),'')
                    )  separator ',')
            )
        INTO 
            fieldlist
        FROM
            ds_column
            join ds_column_list_label
                on (ds_column.table_name, ds_column.column_name) = (ds_column_list_label.table_name, ds_column_list_label.column_name)
                and ds_column_list_label.active=1
            join ds_column x on (x.table_name,x.column_name) = (readtable,ds_column.column_name)
        WHERE
            ds_column.table_name = JSON_VALUE(request,'$.tablename')
            and ds_column.existsreal=1
        */

        
        TualoApplication::timing("ds read procedure ".$tablename,'');
        $queryparams = array(

            'tablename'=>$tablename,
            'replaced'=>0,
            'comibedfieldname'=>1,
            'calcrows'=>1,

            'filter'=>(isset($request['filter'])&& is_string($request['filter'])?json_decode($request['filter'],true): (isset($request['filter']) && is_array( $request['filter'] )?$request['filter']:[]) ),
            'sort'=>(isset($request['sort'])&& is_string($request['sort'])?json_decode($request['sort'],true): (isset($request['sort']) && is_array( $request['sort'] )?$request['sort']:[]) ),

            'page'=> (isset($request['page']))?intval($request['page']):1,
            'start'=> (isset($request['start']))?intval($request['start']):0,
            'limit'=> (isset($request['limit']))?intval($request['limit']):100,

            //'search'=> (isset($request['query']) ? $request['query']:'')

        );

        if (isset($request['reference'])){
            if (is_string($request['reference'])) $request['reference']=json_decode($request['reference'],true);
            foreach($request['reference'] as $key=>$val){
                $queryparams['filter'][]=['operator'=>'==','value'=>$val,'property'=>$key];
            }
        }
        $sqlhash = '0';
        $s = $db->singleValue('SELECT fn_ds_read({r}) s',['r'=>json_encode($queryparams)],'s');
        TualoApplication::timing("ds read fn_ds_read ".$tablename,'');

        if ($queryparams['replaced']==0){
            //file_put_contents(TualoApplication::get("basePath").'/cache/'.$db->dbname.'/readcache/'.$sqlhash,$s);
        }
        TualoApplication::result('s',$s);

        if ($queryparams['replaced']==0){
            $hashed = DSReadRoute::getFilterValuesHashed($db,$queryparams,true);

            TualoApplication::result('hashed_array',$hashed);

            $s = DataRenderer::renderTemplate($s,$hashed,true,true);
            $hashed = DSReadRoute::getFilterValuesHashed($db,$queryparams);
            $s = $db->replace_hash($s, $hashed);
        }

        $_SESSION['debug']='1';
        if (isset($_SESSION['typ'])&&($_SESSION['typ']=='master')){
            if (isset($_SESSION['debug'])&&($_SESSION['debug']=='1')){
                TualoApplication::result('queryparams', json_encode($queryparams) );
                TualoApplication::result('qsql',$s);
            }
        }
        TualoApplication::result('qsql',$s);

        $db->direct( 'SET @rownum=0;' ); // old db versions lower than maria 10.
        $result['data'] = DSReadRoute::shortFieldNames($request,$db->direct( $s ));
        TualoApplication::timing("ds read query ".$tablename,'');
        TualoApplication::logger('dsreadroute')->debug($tablename." ".$db->last_sql." ");
        TualoApplication::debug($s);
        
        $result['total'] = $db->singleValue('select found_rows() total',array(),'total');
        TualoApplication::timing("ds read found_rows ".$tablename,'');
        $time_stop=microtime(true); 
        TualoApplication::logger('timing')->error($tablename." ".number_format($time_stop-$time_start,5)."s");
        TualoApplication::logger('timing')->error($tablename." ".number_format($result['total'] ,0,'.',',')."records");

        return $result;
    }

    public static function readSingleItem($db,$tablename,$request){
        $res = self::read($db,$tablename,$request);
        if ($res['total']>=1){
            return $res['data']['0'];
        }
        return false;
    }

    public static function shortFieldNames($request,$dataArray){
        if (isset($request['shortfieldnames'])&&($request['shortfieldnames']==1)){
            foreach($dataArray as &$item){
                foreach($item as $key => $data){
                    if(strpos($key,'__')!==0){
                        $item[str_replace($item['__table_name'].'__','',$key)]=$data;
                        unset($item[$key]);
                    }
                }
            }

        }
        return $dataArray;
    }



    public static function readObject($db,$object,$objectId,$request,$referenceFilter=array()){
        $result = array();
        $tablename = $db->singleValue('select table_name from ds_object where id = {object}  ',array('object'=>$object) ,'table_name');
        if (!isset($request['shortfieldnames']))  $request['shortfieldnames']=1;

        if (count($referenceFilter)==0){
            $request['filter'] = array(
                array( 
                    'property' => '__id',
                    'operator' => '=',
                    'value'    => $objectId
                )
            );
        }else{
            $request['filter'] = $referenceFilter;
        }

        
        $result = DSReadRoute::read($db,$tablename,$request);
        $result = $result['data'];

        $childsnodes = $db->direct('select id,parent,table_name from ds_object where parent = {object}  ',array('object'=>$object));
        if ($childsnodes){
            foreach($result as &$record){
                foreach($childsnodes as $child){
                    $refjson = $db->singleRow('select columnsdef from ds_reference_tables where reference_table_name ={parent}  and table_name={table_name}',$child,'');
                    if ($refjson!==false){
                        $ref = json_decode($refjson['columnsdef'],true);
                        $referenceFilter = array();
                        foreach($ref as $k=>$v){
                            $vx = $v;
                            if ($request['shortfieldnames']==1) $vx = str_replace($child['parent'].'__','',$v);
                            $referenceFilter[] = [ 'property'=>$k, 'operator'=>'eq', 'value'=>$record[$vx] ];
                        }
                        $record[$child['id']] = DSReadRoute::readObject($db,$child['id'],$record['__id'],$request,$referenceFilter);
                    }
                }
            }
        }
        return $result;
    }
}