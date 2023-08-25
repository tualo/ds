<?php
namespace Tualo\Office\DS\Checks;

use Tualo\Office\Basic\Middleware\Session;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\TualoApplication as App;


class Tables  extends PostCheck {
    
    public static function test(array $config){
        $clientdb = App::get('clientDB');
        if (is_null($clientdb)) return;
        $tables = [
            'ds'=>[
                'columns'=>[
                    'table_name'=>'varchar(128)'
                ]
            ],
            'ds_column'=>[],
            'ds_column_list_label'=>[],
            'ds_column_form_label'=>[],
            'view_ds_column'=>['filename'=>'text', 'js'=>'longtext', 'name'=>'varchar(100)', 'table_name'=>'varchar(128)'],
            'view_ds_combobox'=>['filename'=>'text', 'js'=>'longtext', 'name'=>'varchar(100)', 'table_name'=>'varchar(128)'],
            'view_ds_controller'=>['filename'=>'text', 'js'=>'longtext', 'jsx'=>'longtext', 'table_name'=>'varchar(128)'],
            'view_ds_dsview'=>['filename'=>'text', 'js'=>'longtext', 'table_name'=>'varchar(128)'],
            'view_ds_form'=>['filename'=>'text', 'js'=>'longtext', 'jsx'=>'longtext', 'table_name'=>'varchar(128)'],
            'view_ds_list'=>['filename'=>'text', 'js'=>'longtext', 'jsx'=>'longtext', 'table_name'=>'varchar(128)'],
            'view_ds_listcolumn'=>['js'=>'longtext', 'requiresJS'=>'longtext', 'table_name'=>'varchar(128)'],
            'view_ds_model'=>['filename'=>'text', 'js'=>'longtext', 'name'=>'text', 'table_name'=>'varchar(128)'],
            'view_ds_store'=>['filename'=>'text', 'js'=>'longtext', 'name'=>'text', 'table_name'=>'varchar(128)']
        ];
        self::tableCheck('ds',$tables,
            "please run the following command: `./tm install-sql-ds --client ".$clientdb->dbname."`",
            "please run the following command: `./tm install-sql-ds --client ".$clientdb->dbname."`"

        );
    }
}