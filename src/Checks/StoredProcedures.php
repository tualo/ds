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
            'dsx_get_key_sql'=>'f452ab71edbfa2adf7b16867bdfa0077',
            'dsx_get_key_sql_prefix'=>'535002a61e8621194e93820b9dea7a16',
            'dsx_filter_term'=>'54352cc2aef440d4d30e111106907d51',
            'dsx_filter_values_extract'=>'302f4d9815bb7b237bf32afb75c522db',
            'dsx_rest_api_get'=>'bd005ad88ec24753dc772514d016d608',
            'dsx_rest_api_set'=>'23bfd2d150f57cade7d46b83117baceb',
            'ds_create_fulltext_search'=>'1a66bf141d48f3eb435a2958d6caa4ed'
        ];
        self::procedureCheck(
            'ds',
            $def,
            "please run the following command: `./tm install-sql-ds --client ".$clientdb->dbname."`",
            "please run the following command: `./tm install-sql-ds --client ".$clientdb->dbname."`"
        );
        
    }
}