<?php
namespace Tualo\Office\DS\Commandline;
use Tualo\Office\Basic\ICommandline;
use Tualo\Office\Basic\CommandLineInstallSQL;

class InstallDSX extends CommandLineInstallSQL  implements ICommandline{
    public static function getDir():string {   return dirname(__DIR__,1); }
    public static $shortName  = 'ds-dsx';
    public static $files = [
        'dsx/000.dsx_filter_values' => 'setup 000.dsx_filter_values ',
        'dsx/000.dsx_filter_values_extract' => 'setup 000.dsx_filter_values_extract ',
        'dsx/000.dsx_get_key_sql' => 'setup 000.dsx_get_key_sql ',
        'dsx/001.dsx_filter_operator' => 'setup 001.dsx_filter_operator ',
        'dsx/create_or_upgrade_hstr_table' => 'setup create_or_upgrade_hstr_table ',
        'dsx/dsx_read_order' => 'setup dsx_read_order ',
        'dsx/dsx_rest_api_get' => 'setup dsx_rest_api_get ',
        'dsx/dsx_rest_api_set' => 'setup dsx_rest_api_set ',
    ];
    
}


