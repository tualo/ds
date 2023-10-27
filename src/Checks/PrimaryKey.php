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
            'select ds_column.table_name,1 writeable ,max(ds_column.is_primary) has_is_primary from ds_column join ds on ds_column.table_name=ds.table_name group by ds_column.table_name having has_is_primary=0'
        );
        foreach($data as $row){
            if ($row['writeable']==1){
                self::formatPrintLn(['red'], $row['table_name'].' table '.$clientdb->dbname.'.'.$row['table_name'].' has no primary key');
            }else{
                self::formatPrintLn(['yellow'], $row['table_name'].' view '.$clientdb->dbname.'.'.$row['table_name'].' has no primary ');
            }
        }
        

    }
}
