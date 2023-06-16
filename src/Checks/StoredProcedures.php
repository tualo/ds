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
        and routine_name in ('dsx_rest_api_get','dsx_rest_api_set')
        */

        $def = [
            'dsx_rest_api_get'=>'c79762e9ebdf6cd607e61086cfa681bc',
            'dsx_rest_api_set'=>'3c33a487ecde7b34507b8be91f50f8b4'
        ];
        self::procedureCheck($def);
        
    }
}