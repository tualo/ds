<?php

namespace Tualo\Office\DS\Checks;

use Tualo\Office\Basic\Middleware\Session;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\TualoApplication as App;


class StoredProcedures extends PostCheck
{


    public static function test(array $config)
    {
        $clientdb = App::get('clientDB');
        if (is_null($clientdb)) return;
        $def = [
            'dsx_rest_api_unescape' => '3c1a32b3abe38f0766fc492abdf90e11',
            'dsx_filter_proc' => 'a5fcad4fb7ac60a5cead96de31794ac4',
            'dsx_read_order' => '8163802ef4b62bdd5294b853e36d26ca',
            'create_or_upgrade_hstr_table' => 'ad429a9b1ae27217a536bede47edaf2e',
            'dsx_filter_operator' => '02052d4b2764748d2dd99d70902a4f18',
            'dsx_get_key_sql' => '9dd4bf05f039f4f8cbd447c16df05cfe',
            'dsx_get_key_sql_prefix' => '9d2af627f43fc988f26cd4902eabe998',
            'dsx_filter_term' => '54352cc2aef440d4d30e111106907d51',
            'dsx_filter_values_extract' => '302f4d9815bb7b237bf32afb75c522db',
            'dsx_rest_api_get' => 'ee98268f7b89e9d3a628a68302126411',
            'dsx_rest_api_set' => 'ac69f194061d93c7d5f8b945d5e202d4',
            'ds_create_fulltext_search' => '4a247175446edccbc654941dfba42dd7'
        ];
        self::procedureCheck(
            'ds',
            $def,
            "please run the following command: `./tm install-sql-ds --client " . $clientdb->dbname . "`",
            "please run the following command: `./tm install-sql-ds --client " . $clientdb->dbname . "`"
        );
    }
}
