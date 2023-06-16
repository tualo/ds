<?php
namespace Tualo\Office\DS\Checks;

use Tualo\Office\Basic\Middleware\Session;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\TualoApplication as App;


class Tables  extends PostCheck {
    
    public static function test(array $config){
        // print_r($config);
        $tables = [
            'ds'=>[],
            'ds_column'=>[],
            'ds_column_list_label'=>[],
            'ds_column_form_label'=>[]
        ];
        self::tableCheck('ds',$tables);
    }
}