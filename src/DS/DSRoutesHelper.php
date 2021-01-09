<?php


class DSRoutesHelper{
    public static $triggers=array();
    
    public static function initDSTrigger($tablename){
          $trigger = $this->db->direct('select program from `ds_trigger` where table_name={table_name}',array('table_name'=>$tablename));
          foreach ($trigger as $row) {
            self::$triggers[] = TualoApplication::get('basePath').'/cmp/'.$row['program'];
          }
        
    }

    public static function initQuery($db,$tablename,$queryparams,$request){
        $queries = array();

        $db->direct('set group_concat_max_len=2048576000;');
        TualoApplication::debug( $db->last_sql );

        $uuid = $db->singleValue( 'SELECT uuid() u', $queryparams ,'u');
        TualoApplication::debug( $db->last_sql );
        
        $queries[]=$db->last_sql;
        $db->direct( 'SET @queryid = {uuid}',array('uuid'=>$uuid));
        TualoApplication::debug( $db->last_sql );
        $GLOBALS['debug_query'][] = $db->last_sql;
        $queries[]=$db->last_sql;
        $db->direct( 'call cleanDSQuery(@queryid)');
        TualoApplication::debug( $db->last_sql );
        $GLOBALS['debug_query'][] = $db->last_sql;
        $queries[]=$db->last_sql;
        $db->direct( 'call initializeDSQuery(@queryid,{query_type},{table_name});', $queryparams );
        TualoApplication::debug( $db->last_sql );
        $GLOBALS['debug_query'][] = $db->last_sql;
        $queries[]=$db->last_sql;
        $db->direct( 'call setDSQueryLimits(@queryid,{query_start},{query_limit});', $queryparams );
        TualoApplication::debug( $db->last_sql );
        $GLOBALS['debug_query'][] = $db->last_sql;
        $queries[]=$db->last_sql;

        return $queries;
    }



    public static function setSort($db,$tablename,$queryparams,$request){
        if (isset($request['sort'])){
            $sortobject = array();
            if (is_array($request['sort'])){
                $sortobject = $request['sort'];
            }else{
                $sortobject = json_decode($request['sort'],true);
            }
            $position=0;
            $GLOBALS['debug_query'][] = print_r($sortobject,true);
            foreach($sortobject as $sorter){
                $sorter['position'] = $position++;
                $db->direct( 'call addDSOrderFieldByFieldName(@queryid,{property},{direction},{position})',array_merge($sorter,$queryparams));
                TualoApplication::debug( $db->last_sql );
                $GLOBALS['debug_query'][] = $db->last_sql;
            }
        }
    }


    public static function filterObject($db,$tablename,$queryparams,$request){
        $filterobject =array();
        if (isset($request['filter'])){
            if (is_string($request['filter'])){
                $filterobject = json_decode($request['filter'],true);
            }else if(is_array($request['filter'])){
                $filterobject = $request['filter'];
            }
        }
        
        if (isset($request['reference'])){
            $referenceobject = json_decode($request['reference'],true);
            foreach($referenceobject as $key=>$value){
                $filterobject[] = array(
                    'property'  => $key,
                    'location'  => 'where',
                    'operator'  => '=',
                    'value'     =>  $value
                );
            }
        }
        if (isset($request['query'])){


            $request['query'] = preg_replace("/[\+\-]$/","",$request['query']);
                //print_r($request);exit();
            if ($db->singleRow('select daten from setup where id=\'DS_USE_MULTI_SEARCH\' and cmp=\'cmp_ds\' and daten=\'1\' ')!==false){
                $db->direct('SET @searchquery = {query}',$request);
            }else{

                $query = trim($request['query']).'%';
                $queryField = $db->singleValue('select searchfield from ds where table_name={table_name}',$queryparams,'searchfield');
                TualoApplication::debug( $db->last_sql );
                $GLOBALS['debug_query'][] = $db->last_sql;
                $queryFieldAny = $db->singleValue('select searchany from ds where table_name={table_name}',$queryparams,'searchany');
                $GLOBALS['debug_query'][] = $db->last_sql;
                TualoApplication::debug( $db->last_sql );
                if (isset($request['queryField'])){
                    $queryField = $request['queryField'];
                }
                if ( $queryFieldAny==1 ){
                    $query='%'.$query;
                }
                $filterobject[] = array(
                    'property'  => $tablename .'__'.$queryField,
                    'location'  => 'having',
                    'operator'  => 'like',
                    'value'     => $query
                );
            }
        }

        foreach($filterobject as $filter){
            if (!isset(($filter['value']))) continue;

            if(!isset($filter['location'])){
                $filter['location']='where';
            }
            if (is_array($filter['value'])){
                $cvalue = $filter;
                foreach($filter['value'] as $fvalue){
                    $cvalue['value']=$fvalue;
                    $db->direct( 'call addDSQueryFilterByFieldName(@queryid,{property},{location},{operator},{value})',array_merge($cvalue,$queryparams) );
                    TualoApplication::debug( $db->last_sql );
                    $GLOBALS['debug_query'][] = $db->last_sql;
                }
            }else{
                $db->direct( 'call addDSQueryFilterByFieldName(@queryid,{property},{location},{operator},{value})',array_merge($filter,$queryparams));
                $GLOBALS['debug_query'][] = $db->last_sql;
                TualoApplication::debug( $db->last_sql );
            }
        }
        
    }
}
