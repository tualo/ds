<?php

namespace Tualo\Office\DS\Checks;

use Tualo\Office\Basic\Middleware\Session;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\TualoApplication as App;


class StoredProcedures extends PostCheck {

    
    public static function test(array $config){
        // print_r($config);
        /*
        select routine_name,md5(routine_definition) md5 from information_schema.routines WHERE routine_schema = database() 
        and routine_name in (
            'dsx_rest_api_get','dsx_rest_api_set',
            'dsx_filter_values_extract',
            'dsx_filter_term',
            'dsx_get_key_sql',
            'dsx_filter_operator',
            'create_or_upgrade_hstr_table',
            'dsx_read_order',
            'dsx_filter_proc',
            'dsx_rest_api_unescape'
        )
        */

        $def = [
            'dsx_rest_api_unescape'=>'3c1a32b3abe38f0766fc492abdf90e11',
            'dsx_filter_proc'=>'a5fcad4fb7ac60a5cead96de31794ac4',
            'dsx_read_order'=>'438775628deb3dc4a83c238f1f2be89e',
            'create_or_upgrade_hstr_table'=>'ad429a9b1ae27217a536bede47edaf2e',
            'dsx_filter_operator'=>'8841e1840ec0dff0a44c1ea43020687e',
            'dsx_get_key_sql'=>'3275f6c90b641c0fc49d85e747342d89',
            'dsx_filter_term'=>'54352cc2aef440d4d30e111106907d51',
            'dsx_filter_values_extract'=>'302f4d9815bb7b237bf32afb75c522db',
            'dsx_rest_api_get'=>'c79762e9ebdf6cd607e61086cfa681bc',
            'dsx_rest_api_set'=>'3f4801efaf0b1ab662f618d48207628a'
        ];
        self::procedureCheck('ds',$def);
        
    }
}