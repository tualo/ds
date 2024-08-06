<?php

namespace Tualo\Office\DS\Checks;

use Tualo\Office\Basic\Middleware\Session;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\TualoApplication as App;


class StoredProcedures extends PostCheck {

    
    public static function test(array $config){
        $clientdb = App::get('clientDB');
        if (is_null($clientdb)) return;
        $def = [
            'dsx_rest_api_unescape'=>'3c1a32b3abe38f0766fc492abdf90e11',
            'dsx_filter_proc'=>'a5fcad4fb7ac60a5cead96de31794ac4',
            'dsx_read_order'=>'8163802ef4b62bdd5294b853e36d26ca',
            'create_or_upgrade_hstr_table'=>'ad429a9b1ae27217a536bede47edaf2e',
            'dsx_filter_operator'=>'8841e1840ec0dff0a44c1ea43020687e',
            'dsx_get_key_sql'=>'3275f6c90b641c0fc49d85e747342d89',
            'dsx_get_key_sql_prefix'=>'702b60315bc7c1103dc0a51d5570246e',
            'dsx_filter_term'=>'54352cc2aef440d4d30e111106907d51',
            'dsx_filter_values_extract'=>'302f4d9815bb7b237bf32afb75c522db',
            'dsx_rest_api_get'=>'3f0eaa8c845f2065502577aac69478fd',
            'dsx_rest_api_set'=>'5370db244696c31a4e07bd982e8c5cf8'
        ];
        self::procedureCheck(
            'ds',
            $def,
            "please run the following command: `./tm install-sql-ds --client ".$clientdb->dbname."`",
            "please run the following command: `./tm install-sql-ds --client ".$clientdb->dbname."`"
        );
        
    }
}