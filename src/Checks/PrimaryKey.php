<?php
namespace Tualo\Office\DS\Checks;

use Tualo\Office\Basic\Middleware\Session;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\TualoApplication as App;


class PrimaryKey  extends PostCheck {
    
    public static function test(array $config){
        $clientdb = App::get('clientDB');
        if (is_null($clientdb)) return;

        $data = $clientdb->direct(
            'select table_name,max(is_primary) has_is_primary from ds_column group by table_name having has_is_primary=0'
        );
        foreach($data as $row){
            self::formatPrintLn(['red'], 'table '.$clientdb->dbname.'.'.$row['table_name'].' has no primary key');
        }
        

    }
}
